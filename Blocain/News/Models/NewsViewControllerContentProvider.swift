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
}


protocol NewsViewControllerContentProviderProtocol: CIContentProviderProtocol {
    var content: NewsViewControllerContentProtocol {get}
    var index: Int {get set}
    
    func fetch(singleTopicAt index: Int)
    func fetchNextPage()
    func pullToRefresh()
    
    func favoriteItem(at index: Int)
}


class NewsViewControllerContentProvider: CIContentProvider, NewsViewControllerContentProviderProtocol {
    var content: NewsViewControllerContentProtocol
    private var contentFetcher = NewsContentFetcher.defaultFetcher
    
    var index: Int = 0
    
    private var isLoadingNextPage = false
    
    private var alreadyLoadedPageArray = [Int]()
    
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
                            
                            Firestore.firestore().document("/Topics/F4qqmZj5Dvz9ar8px9ze").getDocument(completion: { (snapshot, error) in
                                processingQueue?.async {
                                    guard let snapshot = snapshot, error == nil else {
                                        self?.defaultErrorBlock()
                                        return
                                    }
                                    
                                    if let data: [String: Any] = snapshot.data() {
                                        if let topicArray = data["topicName"] as? [String] {
                                            self?.content.titlesArray.append(contentsOf: topicArray)
                                            self?.alreadyLoadedPageArray = [Int](repeating: 1, count: topicArray.count)
                                        }
                                    }
                                    
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
                            })
                        }
                    }
                })
                
                

            })
        }
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
    
    
    func pullToRefresh() {
        alreadyLoadedPageArray[index] = 0
        content.contentsDictionary[content.titlesArray[index]]?.removeAll()
        content.contentsViewModelDictionary[content.titlesArray[index]]?.removeAll()
        fetchNextPage()
    }
    
    
    func favoriteItem(at index: Int) {
        
    }
}


struct NewsViewControllerContent: NewsViewControllerContentProtocol {
    var titlesArray: [String]
    var contentsDictionary: [String: [NewsContentEntity]]
    var contentsViewModelDictionary: [String: [NewsTableViewCellModelProtocol]]
    
    init(titlesArray: [String]? = nil, contentsDictionary: [String: [NewsContentEntity]]? = nil, contentsViewModelDictionary: [String: [NewsTableViewCellModelProtocol]]? = nil) {
        self.titlesArray = titlesArray == nil ? [String]() : titlesArray!
        self.contentsDictionary = contentsDictionary == nil ? [String: [NewsContentEntity]]() : contentsDictionary!
        self.contentsViewModelDictionary = contentsViewModelDictionary == nil ? [String: [NewsTableViewCellModelProtocol]]() : contentsViewModelDictionary!
    }
}
