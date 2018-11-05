//
//  NewsViewControllerContentProvider.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/24.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Mixpanel

protocol NewsViewControllerContentProtocol {
    var titlesArray: [String] {get set}
    var contentsDictionary: [String: [NewsDataModel]] {get set}
    var contentsViewModelDictionary: [String: [NewsTableViewCellViewModelProtocol]] {get set}
    var topicsDataArray: [TopicDataModel] {get set}
    var topTabBarTopicsDataArray: [TopicDataModel] {get set}
}


protocol NewsViewControllerContentProviderProtocol: CIContentProviderProtocol {
    var index: Int {get set}
    var content: NewsViewControllerContent { get }
    func fetch(singleTopicAt index: Int) -> Bool
    func fetchNextPage()
    func pullToRefresh()
    func refreshTopicsAndNewsItems()
    func didChange(favouriteNewsItemWith id: Int, isFavourited: Bool)
}


struct NewsViewControllerContent: NewsViewControllerContentProtocol {
    var titlesArray: [String]
    var contentsDictionary: [String: [NewsDataModel]]
    var contentsViewModelDictionary: [String: [NewsTableViewCellViewModelProtocol]]
    var topicsDataArray: [TopicDataModel]
    var topTabBarTopicsDataArray: [TopicDataModel]
    var nextPageCursorDictionary: [String: String]
    
    init(titlesArray: [String]? = nil,
         contentsDictionary: [String: [NewsDataModel]]? = nil,
         contentsViewModelDictionary: [String: [NewsTableViewCellViewModelProtocol]]? = nil,
         topicsDataArray: [TopicDataModel]? = nil,
         topTabBarTopicsDataArray: [TopicDataModel]? = nil,
         nextPageCursorDictionary: [String: String]? = nil)
    {
        
        self.titlesArray = titlesArray == nil ? [String]() : titlesArray!
        self.contentsDictionary = contentsDictionary == nil ? [String: [NewsDataModel]]() : contentsDictionary!
        self.contentsViewModelDictionary = contentsViewModelDictionary == nil ? [String: [NewsTableViewCellViewModelProtocol]]() : contentsViewModelDictionary!
        self.topicsDataArray = topicsDataArray == nil ? [TopicDataModel]() : topicsDataArray!
        self.topTabBarTopicsDataArray = topTabBarTopicsDataArray == nil ? [TopicDataModel]() : topTabBarTopicsDataArray!
        self.nextPageCursorDictionary = nextPageCursorDictionary == nil ? [String: String]() : nextPageCursorDictionary!
        
    }
}


class NewsViewControllerContentProvider: CIContentProvider, NewsViewControllerContentProviderProtocol {
    
    var content: NewsViewControllerContent
    private var contentFetcher = NewsContentFetcher.defaultFetcher
    
    var index: Int = 0
    
    private var isLoadingNextPage = false
    
    private var topicDataModelArray = [TopicDataModel]()
    
    override init() {
        content = NewsViewControllerContent()
        
        super.init()
    }
    
    
    override func refresh() {
        let processingQueue = self.processingQueue
        processingQueue.async { [weak self] in
            let firestore = CIFirestore.sharedInstance
            firestore.waitForConfigureWith(completionQueue: processingQueue, completion: {
                TopicManager.sharedManager.fetchCombinedTopicsDataModels(processingQueue: processingQueue) { (localTopicDataModelArray, remoteDataModelArray, combinedDataModelArray, error) in
                    guard let self = self else { return }
                    guard let combinedDataModelArray = combinedDataModelArray, error == nil else { return }
                    self.content.topicsDataArray = combinedDataModelArray
                    
                    let sortedTopicDataModelArray = combinedDataModelArray.filter({ (topicDataModel) -> Bool in
                        return topicDataModel.isSelected
                    })
                    self.content.topTabBarTopicsDataArray = sortedTopicDataModelArray
                    
                    var topicNameArray = [String]()
                    sortedTopicDataModelArray.forEach({ (topicDataModel) in
                        topicNameArray.append(topicDataModel.name)
                    })
                    
                    self.content.titlesArray.removeAll()
                    self.content.titlesArray.append(contentsOf: topicNameArray)
                    self.fetch(singleTopicAt: self.index)
                }
            })
        }
    }
    
    
    func refreshTopicsAndNewsItems() {
        let localTopicDataModelArray = TopicManager.sharedManager.getTopicDataModelArrayFromUserDefaults().filter { (topicDataModel) -> Bool in
            return topicDataModel.isSelected
        }
        self.content.topTabBarTopicsDataArray.removeAll()
        self.content.topTabBarTopicsDataArray = localTopicDataModelArray
        
        var topicNameArray = [String]()
        localTopicDataModelArray.forEach({ (topicDataModel) in
            topicNameArray.append(topicDataModel.name)
        })
        self.content.titlesArray.removeAll()
        self.content.titlesArray.append(contentsOf: topicNameArray)
        
        self.content.contentsViewModelDictionary.removeAll()
        self.content.contentsDictionary.removeAll()
        fetch(singleTopicAt: index)
    }
    
    
    @discardableResult func fetch(singleTopicAt index: Int) -> Bool {
        guard index < content.titlesArray.count else {
            setContentOnMainThread(content)
            return false
        }
        
        let title = content.titlesArray[index]
        if content.contentsDictionary[title] != nil { return false }
        
        contentFetcher.fetchAylienNewsContent(with: self.content.topTabBarTopicsDataArray[index], pageCursor: nil, processingQueue: processingQueue) { (newsDataArray, nextPageCursor, success) in
            if success {
                guard let newsDataArray = newsDataArray, let nextPageCursor = nextPageCursor, success == true else {
                    self.setContentOnMainThread(self.content)
                    return
                }
                
                let newsTableViewCellViewModelArray: [NewsTableViewCellViewModelProtocol] = newsDataArray.map {
                    return NewsTableViewCellViewModel(with: $0)
                }
                
                self.content.nextPageCursorDictionary[title] = nextPageCursor
                self.content.contentsDictionary[title] = newsDataArray
                self.content.contentsViewModelDictionary[title] = newsTableViewCellViewModelArray
                self.setContentOnMainThread(self.content)
            }else {
                self.setErrorOnMainThread()
            }
        }
        
        return true
    }
    
    
    func fetchNextPage() {
        if !isLoadingNextPage {
            isLoadingNextPage = true
            let processingQueue = self.processingQueue
            processingQueue.async {[weak self] in
                guard let self = self else { return }
                
                let nextPageCursor = self.content.nextPageCursorDictionary[self.content.titlesArray[self.index]]
        
                self.contentFetcher.fetchAylienNewsContent(with: self.content.topicsDataArray[self.index], pageCursor: nextPageCursor, processingQueue: processingQueue, completion: { (newsDataArray, nextPageCursor, success) in
                    if success {
                        guard let newsDataArray = newsDataArray, let nextPageCursor = nextPageCursor, success == true else {
                            self.setContentOnMainThread(self.content)
                            return
                        }
                        
                        if var currentContent = self.content.contentsDictionary[self.content.titlesArray[self.index]] {
                            currentContent.append(contentsOf: newsDataArray)
                            self.content.contentsDictionary[self.content.titlesArray[self.index]] = currentContent
                        }
                        
                        if var currentContentViewModels = self.content.contentsViewModelDictionary[self.content.titlesArray[self.index]] {
                            let newsTableViewCellViewModelArray: [NewsTableViewCellViewModelProtocol] = newsDataArray.map {
                                return NewsTableViewCellViewModel(with: $0)
                            }
                            currentContentViewModels.append(contentsOf: newsTableViewCellViewModelArray)
                            self.content.contentsViewModelDictionary[self.content.titlesArray[self.index]] = currentContentViewModels
                        }
                        
                        
                        self.content.nextPageCursorDictionary[self.content.titlesArray[self.index]] = nextPageCursor
                        self.addNewContent(onMainThread: self.content)
                    }else {
                        self.setErrorOnMainThread()
                    }
                    
                    self.isLoadingNextPage = false
                })
            }
        }
    }
    
    
    func pullToRefresh() {
        content.contentsDictionary[content.titlesArray[index]] = nil
        content.contentsViewModelDictionary[content.titlesArray[index]] = nil
        content.nextPageCursorDictionary[content.titlesArray[index]] = nil
        trackPullToRefreshEvent()
        fetch(singleTopicAt: index)
    }
    
    
    private func trackPullToRefreshEvent() {
        var propertyList = Properties()
        propertyList["Pulled to Refresh Topic"] = content.titlesArray[index]
        AnalyticManager.sharedManager.trackEvent(with: "Refresh Page", propertiesList: propertyList)
    }
    
    
    func didChange(favouriteNewsItemWith id: Int, isFavourited: Bool) {
        for key in content.contentsViewModelDictionary.keys {
            let viewModelArrays = content.contentsViewModelDictionary[key]
            viewModelArrays?.forEach({ (viewModel) in
                if viewModel.id == id {
                    var viewModel = viewModel
                    viewModel.shouldShowBookmarkImage = isFavourited
                }
            })
        }
    }
}
