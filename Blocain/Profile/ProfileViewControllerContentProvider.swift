//
//  ProfileViewControllerContentProvider.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/8/3.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

import Mixpanel

protocol ProfileViewControllerContentProtocol {
    var newsFavouriteDataModelsArray: [NewsFavouriteDataModel] { get set }
    var newsTableViewCellViewModelsArray: [NewsTableViewCellViewModel] { get set }
}


protocol ProfileViewControllerContentProviderProtocol: CIContentProviderProtocol {
    var content: ProfileViewControllerContentProtocol { get }
    
    func didWantToUnFavourite(at index: Int)
}


struct ProfileViewControllerContent: ProfileViewControllerContentProtocol {
    var newsFavouriteDataModelsArray: [NewsFavouriteDataModel]
    var newsTableViewCellViewModelsArray: [NewsTableViewCellViewModel]
    
    init(newsFavouriteDataModelsArray: [NewsFavouriteDataModel]? = nil, newsTableViewCellViewModelsArray: [NewsTableViewCellViewModel]? = nil) {
        self.newsFavouriteDataModelsArray = newsFavouriteDataModelsArray == nil ? [NewsFavouriteDataModel]() : newsFavouriteDataModelsArray!
        self.newsTableViewCellViewModelsArray = newsTableViewCellViewModelsArray == nil ? [NewsTableViewCellViewModel]() : newsTableViewCellViewModelsArray!
    }
}


class ProfileViewControllerContentProvider: CIContentProvider, ProfileViewControllerContentProviderProtocol {
    var content: ProfileViewControllerContentProtocol
    
    
    override init() {
        content = ProfileViewControllerContent(newsFavouriteDataModelsArray: nil, newsTableViewCellViewModelsArray: nil)
    }
    
    
    override func refresh() {
        let processingQueue = self.processingQueue
        processingQueue.async {
            let favouriteNewsDataModelsSet = FavouriteManager.sharedManager.favouriteNewsDataModelsSet
            let favouriteNewsDataModelsArray = Array(favouriteNewsDataModelsSet)
            self.content.newsFavouriteDataModelsArray = favouriteNewsDataModelsArray.sorted(by: { (m1, m2) -> Bool in
                guard let date1 = m1.date, let date2 = m2.date else { return false }
                
                return date1 > date2
            })
            self.content.newsTableViewCellViewModelsArray = self.content.newsFavouriteDataModelsArray.map {NewsTableViewCellViewModel(with: $0)}
            self.setContentOnMainThread(self.content)
        }
    }
    
    
    func didWantToUnFavourite(at index: Int) {
        trackNewsRemovedEvent(at: index)
        FavouriteManager.sharedManager.didWantToUnFavouriteNewsItem(with: content.newsFavouriteDataModelsArray[index].id ?? 0)
        content.newsFavouriteDataModelsArray.remove(at: index)
        content.newsTableViewCellViewModelsArray.remove(at: index)
        
        assert(content.newsFavouriteDataModelsArray.count == content.newsTableViewCellViewModelsArray.count, "newsFavouriteDataModelsArray's count should be equal with newsTableViewCellViewModelsArray's count")
    }
    
    
    private func trackNewsRemovedEvent(at index: Int) {
        let newsFavouriteDataModel = content.newsFavouriteDataModelsArray[index]
        var propertyList = Properties()
        propertyList["News Removed From"] = "Profile List"
        propertyList["Removed News Source"] = newsFavouriteDataModel.source?.name
        propertyList["Removed News Title"] = newsFavouriteDataModel.title
        propertyList["Removed News Id"] = newsFavouriteDataModel.id
        AnalyticManager.sharedManager.trackEvent(with: "Bookmarked News Removed", propertiesList: propertyList)
    }
    
}
