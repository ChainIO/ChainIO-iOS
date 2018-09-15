//
//  NewsViewControllerContentProvider.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/24.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit
import FirebaseFirestore

protocol NewsViewControllerContentProtocol {
    var titlesArray: [String] {get set}
    var contentsDictionary: [String: [NewsContentEntity]] {get set}
    var contentsViewModelDictionary: [String: [NewsTableViewCellModelProtocol]] {get set}
    var topicsDataArray: [TopicDataModel] {get set}
}


protocol NewsViewControllerContentProviderProtocol: CIContentProviderProtocol {
    var content: NewsViewControllerContentProtocol {get}
    var index: Int {get set}
    
    func fetch(singleTopicAt index: Int)
    func fetchTopics()
    func fetchNextPage()
    func pullToRefresh()
    func refreshTopicsAndNewsItems()
    func favoriteItem(at index: Int)
}


struct NewsViewControllerContent: NewsViewControllerContentProtocol {
    var titlesArray: [String]
    var contentsDictionary: [String: [NewsContentEntity]]
    var contentsViewModelDictionary: [String: [NewsTableViewCellModelProtocol]]
    var topicsDataArray: [TopicDataModel]
    
    init(titlesArray: [String]? = nil, contentsDictionary: [String: [NewsContentEntity]]? = nil, contentsViewModelDictionary: [String: [NewsTableViewCellModelProtocol]]? = nil, topicsDataArray: [TopicDataModel]? = nil) {
        self.titlesArray = titlesArray == nil ? [String]() : titlesArray!
        self.contentsDictionary = contentsDictionary == nil ? [String: [NewsContentEntity]]() : contentsDictionary!
        self.contentsViewModelDictionary = contentsViewModelDictionary == nil ? [String: [NewsTableViewCellModelProtocol]]() : contentsViewModelDictionary!
        self.topicsDataArray = topicsDataArray == nil ? [TopicDataModel]() : topicsDataArray!
    }
}


class NewsViewControllerContentProvider: CIContentProvider, NewsViewControllerContentProviderProtocol {
    var content: NewsViewControllerContentProtocol
    private var contentFetcher = NewsContentFetcher.defaultFetcher
    
    var index: Int = 0
    
    private var isLoadingNextPage = false
    
    private var alreadyLoadedPageArray = [Int]()
    
    private var topicDataModelArray = [TopicDataModel]()
    
    override init() {
        content = NewsViewControllerContent()
        
        super.init()
    }
    
    
    override func refresh() {
        let processingQueue = self.processingQueue
        processingQueue?.async { [weak self] in
            let firestore = CIFirestore.sharedInstance
            firestore.waitForConfigureWith(completionQueue: processingQueue!, completion: {
                Firestore.firestore().document("/WhiteList/J2tgaauOQpni8wiHg1UW").getDocument(completion: { (snapshot, error) in
                    guard let snapshot = snapshot, error == nil else {
                        self?.defaultErrorBlock()
                        return
                    }
                    
                    if let sourceNameData: [String: Any] = snapshot.data() {
                        if let sourceNamesArray = sourceNameData["SourceName"] as? [String] {
                            NewsSourceManager.sharedManager.newsSourceArray = sourceNamesArray
                            TopicManager.sharedManager.fetchCombinedTopicsDataModels(processingQueue: processingQueue!) { (localTopicDataModelArray, remoteDataModelArray, combinedDataModelArray, error) in
                                guard let combinedDataModelArray = combinedDataModelArray, error == nil else { return }
                                self?.content.topicsDataArray = combinedDataModelArray
                                
                                let sortedTopicDataModelArray = combinedDataModelArray.filter({ (topicDataModel) -> Bool in
                                    return topicDataModel.isSelected
                                })
                                var topicNameArray = [String]()
                                sortedTopicDataModelArray.forEach({ (topicDataModel) in
                                    topicNameArray.append(topicDataModel.name)
                                })
                                
                                self?.content.titlesArray.append(contentsOf: topicNameArray)
                                self?.alreadyLoadedPageArray = [Int](repeating: 1, count: topicNameArray.count)
                                
                                guard let titleArray = self?.content.titlesArray else {
                                    self?.setContentOnMainThread(self?.content)
                                    return
                                }
                                
                                guard (self?.index)! < titleArray.count else {
                                    self?.setContentOnMainThread(self?.content)
                                    return
                                }
                                
                                
                                self?.contentFetcher.fetchContent(with: titleArray[(self?.index)!], processingQueue: processingQueue!, completion: { (newsContentEntities, success) in
                                    guard let newsContentEntities = newsContentEntities, success == true else {
                                        self?.setContentOnMainThread(self?.content)
                                        return
                                    }
                                    
                                    let (contents, contentViewModels) = NewsSourceManager.sharedManager.filterContents(newsContentEntitiesArray: newsContentEntities)
                                    self?.content.contentsDictionary[titleArray[(self?.index)!]] = contents
                                    self?.content.contentsViewModelDictionary[titleArray[(self?.index)!]] = contentViewModels
                                    self?.setContentOnMainThread(self?.content)
                                })

                            }
                        }
                    }
                })
            })
        }
    }
    
    
    func refreshTopicsAndNewsItems() {
        let localTopicDataModelArray = TopicManager.sharedManager.getTopicDataModelArrayFromUserDefaults().filter { (topicDataModel) -> Bool in
            return topicDataModel.isSelected
        }
        var topicNameArray = [String]()
        localTopicDataModelArray.forEach({ (topicDataModel) in
            topicNameArray.append(topicDataModel.name)
        })
        self.content.titlesArray.removeAll()
        self.content.titlesArray.append(contentsOf: topicNameArray)
        self.alreadyLoadedPageArray = [Int](repeating: 1, count: topicNameArray.count)
        self.content.contentsDictionary.removeAll()
        fetch(singleTopicAt: index)
    }
    
    
    func fetch(singleTopicAt index: Int) {
        let processingQueue = self.processingQueue
        processingQueue?.async { [weak self] in
            guard let titleArray = self?.content.titlesArray else {
                self?.setContentOnMainThread(self?.content)
                return
            }
            
            guard index < titleArray.count else {
                self?.setContentOnMainThread(self?.content)
                return
            }
            
            if let _ = self?.content.contentsDictionary[titleArray[index]] {
                return
            }
            
            
            self?.contentFetcher.fetchContent(with: titleArray[index], processingQueue: processingQueue!, completion: { (newsContentEntities, success) in
                guard let newsContentEntities = newsContentEntities, success == true else {
                    self?.setContentOnMainThread(self?.content)
                    return
                }
                
                let (contents, contentViewModels) = NewsSourceManager.sharedManager.filterContents(newsContentEntitiesArray: newsContentEntities)
                self?.content.contentsDictionary[titleArray[(self?.index)!]] = contents
                self?.content.contentsViewModelDictionary[titleArray[(self?.index)!]] = contentViewModels
                
                self?.setContentOnMainThread(self?.content)
            })
        }
    }
    
    
    func fetchNextPage() {
        if !isLoadingNextPage {
            isLoadingNextPage = true
            let processingQueue = self.processingQueue
            processingQueue?.async { [weak self] in
                guard let titleArray = self?.content.titlesArray else {
                    self?.setContentOnMainThread(self?.content)
                    return
                }
                
                guard (self?.index)! < titleArray.count else {
                    self?.setContentOnMainThread(self?.content)
                    return
                }
                
                let page = (self?.alreadyLoadedPageArray[(self?.index)!])! + 1
                self?.contentFetcher.fetchContent(with: page, title: titleArray[(self?.index)!], processingQueue: processingQueue!, completion: { (newsContentEntities, success) in
                    guard let newsContentEntities = newsContentEntities, success == true else {
                        self?.setContentOnMainThread(self?.content)
                        return
                    }
                    let (contents, contentViewModels) = NewsSourceManager.sharedManager.filterContents(newsContentEntitiesArray: newsContentEntities)
                    if var currentContent = self?.content.contentsDictionary[titleArray[(self?.index)!]] {
                        currentContent.append(contentsOf: contents)
                        self?.content.contentsDictionary[titleArray[(self?.index)!]] = currentContent
                    }
                    if var currentContentViewModels = self?.content.contentsViewModelDictionary[titleArray[(self?.index)!]] {
                        currentContentViewModels.append(contentsOf: contentViewModels)
                        self?.content.contentsViewModelDictionary[titleArray[(self?.index)!]] = currentContentViewModels
                    }
                    
                    self?.alreadyLoadedPageArray[(self?.index)!] = page
                    self?.addNewContent(onMainThread: self?.content)
                    self?.isLoadingNextPage = false
                })
            }
        }
    }
    
    
    func fetchTopics() {
        
    }
    
    
    func pullToRefresh() {
        alreadyLoadedPageArray[index] = 0
        content.contentsDictionary[content.titlesArray[index]]?.removeAll()
        content.contentsViewModelDictionary[content.titlesArray[index]]?.removeAll()
        fetchNextPage()
    }
    
    
    func favoriteItem(at index: Int) {
        
    }
}
