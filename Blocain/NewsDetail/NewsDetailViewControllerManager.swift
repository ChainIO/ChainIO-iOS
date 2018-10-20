//
//  NewsDetailViewControllerManager.swift
//  Blocain
//
//  Created by Lihao Li on 2018/9/27.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit
import Mixpanel


enum NewsDetailSwipeDirection: String {
    case left
    case right
}


protocol NewsDetailViewControllerManagerProtocol {
    func hasFavouritedCurrentNewsItem() -> Bool
    func didTapFavouriteButton(completion: @escaping (Bool) -> Void)
    func trackExitedEvent(didTapBackButton: Bool)
    func fireNewsOpenedEvent()
    func fireNewsEndDisplayEvent(didOpenFromHomePage: Bool)
    
    func updateIndex(of collectionView: UICollectionView)
    func setContentOffset(of collectionView: UICollectionView)
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
}


class NewsDetailViewControllerManager: NewsDetailViewControllerManagerProtocol {
    
    private var newsDataModelsArray: [NewsDataModel]
    private var containerCellModelsArray: [NewsDetailContainerCollectionViewCellModelProtocol]
    private let topic: String
    var indexInStream: Int
    var swipeDirection: NewsDetailSwipeDirection?
    
    init(newsDataModelsArray: [NewsDataModel], indexInStream: Int, topic: String) {
        self.newsDataModelsArray = newsDataModelsArray
        self.indexInStream = indexInStream
        self.topic = topic
        
        containerCellModelsArray = newsDataModelsArray.map(){NewsDetailContainerCollectionViewCellModel(newsDataModel: $0)}
    }
    
    
    func trackExitedEvent(didTapBackButton: Bool) {
        var propertyList = Properties()
        propertyList["Exited News Action"] = didTapBackButton == true ? "Clicked Back Button" : "Swipe Left"
        AnalyticManager.sharedManager.trackEvent(with: "Exited News", propertiesList: propertyList)
    }
    
    
    func fireNewsOpenedEvent() {
        AnalyticManager.sharedManager.fireEvent(with: "News Opened")
    }
    
    
    func fireNewsEndDisplayEvent(didOpenFromHomePage: Bool) {
        var propertyList = Properties()
        let newsDataModel = newsDataModelsArray[indexInStream]
        propertyList["Topic"] = topic
        propertyList["Opened News From"] = didOpenFromHomePage ? "Home Page" : swipeDirection?.rawValue
        propertyList["Source"] = newsDataModel.source?.name
        propertyList["News Word Count"] = newsDataModel.wordCount
        propertyList["Title"] = newsDataModel.title
        propertyList["Id"] = newsDataModel.id
        propertyList["News Bookmarked"] = hasFavouritedCurrentNewsItem() ? true : false
        AnalyticManager.sharedManager.trackEvent(with: "News Opened", propertiesList: propertyList)
    }
    
    
    private func trackNewsFavouriteEvent(favourited: Bool, newsFavouriteDataModel: NewsDataModel) {
        var propertyList = Properties()
        if favourited {
            propertyList["Bookmarked News Source"] = newsFavouriteDataModel.source?.name
            propertyList["Bookmarked News Word Count"] = newsFavouriteDataModel.wordCount
            propertyList["Bookmarked News Topic"] = topic
            propertyList["Bookmarked News Title"] = newsFavouriteDataModel.title
            propertyList["Bookmarked News Id"] = newsFavouriteDataModel.id
            AnalyticManager.sharedManager.trackEvent(with: "Bookmarked News", propertiesList: propertyList)
        }else {
            propertyList["News Removed From"] = "News Details Page"
            propertyList["Removed News Source"] = newsFavouriteDataModel.source?.name
            propertyList["Removed News Title"] = newsFavouriteDataModel.title
            propertyList["Removed News Source"] = newsFavouriteDataModel.source?.name
            propertyList["Removed News Id"] = newsFavouriteDataModel.id
            AnalyticManager.sharedManager.trackEvent(with: "Bookmarked News Removed", propertiesList: propertyList)
        }
    }
    
    
    // NewsDetailViewControllerManagerProtocol
    
    
    func hasFavouritedCurrentNewsItem() -> Bool {
        assert(indexInStream < newsDataModelsArray.count, "index should less than the total counts of totalNewsDataModelsArray")
        
        let newsDataModel = newsDataModelsArray[indexInStream]
        return FavouriteManager.sharedManager.hasFavouritedNewsItem(newsDataModel)
    }
    
    
    func didTapFavouriteButton(completion: @escaping (Bool) -> Void) {
        let newsDataModel = newsDataModelsArray[indexInStream]
        FavouriteManager.sharedManager.didTapFavouriteButton(newsDataModel) {[weak self] (favourited) in
            guard let self = self else { return }
            
            self.trackNewsFavouriteEvent(favourited: favourited, newsFavouriteDataModel: newsDataModel)
            completion(favourited)
        }
    }
    
    
    func updateIndex(of collectionView: UICollectionView) {
        let currentIndex = Int(collectionView.contentOffset.x / collectionView.bounds.width)
        if currentIndex != indexInStream {
            swipeDirection = currentIndex > indexInStream ? .left : .right
            indexInStream = currentIndex
        }
    }
    
    
    func setContentOffset(of collectionView: UICollectionView) {
        collectionView.contentOffset = CGPoint(x: CGFloat(indexInStream) * collectionView.bounds.width, y: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return containerCellModelsArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsDetailContainerCollectionViewCell.defaultIdentifier, for: indexPath) as! NewsDetailContainerCollectionViewCell
        cell.cellModel = containerCellModelsArray[indexPath.item]
        return cell
    }
    
}
