//
//  FavouriteNewsDetailViewControllerManager.swift
//  Blocain
//
//  Created by Lihao Li on 2018/10/15.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit
import Mixpanel

enum FavouriteNewsDetailSwipeDirection: String {
    case left
    case right
}


protocol FavouriteNewsDetailViewControllerManagerProtocol {
    func hasFavouritedCurrentNewsItem() -> Bool
    func didTapFavouriteButton(completion: @escaping (Bool) -> Void)
    
    func updateIndex(of collectionView: UICollectionView)
    func setContentOffset(of collectionView: UICollectionView)
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
}


class FavouriteNewsDetailViewControllerManager: FavouriteNewsDetailViewControllerManagerProtocol {
    private var newsFavouriteDataModelsArray: [NewsFavouriteDataModel]
    private var containerCellModelsArray: [FavouriteNewsDetailContainerCollectionViewCellModelProtocol]
    var indexInStream: Int
    var swipeDirection: NewsDetailSwipeDirection?
    
    init(newsFavouriteDataModelsArray: [NewsFavouriteDataModel], indexInStream: Int) {
        self.newsFavouriteDataModelsArray = newsFavouriteDataModelsArray
        self.indexInStream = indexInStream
        
        containerCellModelsArray = newsFavouriteDataModelsArray.map(){FavouriteNewsDetailContainerCollectionViewCellModel(newsFavouriteDataModel: $0)}
    }
    
    
    private func trackNewsFavouriteEvent(favourited: Bool, newsFavouriteDataModel: NewsFavouriteDataModel) {
        var propertyList = Properties()
        if favourited {
            propertyList["Bookmarked News Source"] = newsFavouriteDataModel.source?.name
            propertyList["Bookmarked News Word Count"] = newsFavouriteDataModel.wordCount
            propertyList["Bookmarked News Title"] = newsFavouriteDataModel.title
            propertyList["Bookmarked News Id"] = newsFavouriteDataModel.id
            AnalyticManager.sharedManager.trackEvent(with: "Bookmarked News", propertiesList: propertyList)
        }else {
            propertyList["News Removed From"] = "Favorite News Details Page"
            propertyList["Removed News Source"] = newsFavouriteDataModel.source?.name
            propertyList["Removed News Title"] = newsFavouriteDataModel.title
            propertyList["Removed News Source"] = newsFavouriteDataModel.source?.name
            propertyList["Removed News Id"] = newsFavouriteDataModel.id
            AnalyticManager.sharedManager.trackEvent(with: "Bookmarked News Removed", propertiesList: propertyList)
        }
    }
    
    
    // NewsDetailViewControllerManagerProtocol
    
    
    func hasFavouritedCurrentNewsItem() -> Bool {
        if !newsFavouriteDataModelsArray.isEmpty {
            assert(indexInStream < newsFavouriteDataModelsArray.count, "index should less than the total counts of totalNewsDataModelsArray")
        }
        
        let newsDataModel = newsFavouriteDataModelsArray[indexInStream]
        return FavouriteManager.sharedManager.hasFavouritedNewsItem(newsDataModel.id ?? 0)
    }
    
    
    func didTapFavouriteButton(completion: @escaping (Bool) -> Void) {
        let newsFavouriteDataModel = newsFavouriteDataModelsArray[indexInStream]
        FavouriteManager.sharedManager.didTapFavouriteButtonInFavouriteDetailPage(newsFavouriteDataModel) {[weak self] (favourited) in
            guard let self = self else { return }
            
            self.trackNewsFavouriteEvent(favourited: favourited, newsFavouriteDataModel: newsFavouriteDataModel)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavouriteNewsDetailContainerCollectionViewCell.defaultIdentifier, for: indexPath) as! FavouriteNewsDetailContainerCollectionViewCell
        cell.cellModel = containerCellModelsArray[indexPath.item]
        return cell
    }
}
