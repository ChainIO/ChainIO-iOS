//
//  NewsTableViewCellViewModel.swift
//  Blocain
//
//  Created by Lihao Li on 2018/8/20.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

protocol NewsTableViewCellViewModelProtocol {
    var id: Int? {get}
    var sourceName: String? {get}
    var title: String? {get}
    var imageURL: String? {get}
    var publishedAt: String? {get}
    var shouldShowImage: Bool {get}
    var shouldShowBookmarkImage: Bool {get set}
}

class NewsTableViewCellViewModel: NewsTableViewCellViewModelProtocol {
    var id: Int?
    var sourceName: String?
    var title: String?
    var imageURL: String?
    var publishedAt: String?
    var shouldShowImage = false
    var shouldShowBookmarkImage = false
    
    
    init(with newsDataModel: NewsDataModel) {
        id = newsDataModel.id ?? 0
        sourceName = newsDataModel.source?.name ?? ""
        title = newsDataModel.title ?? ""
        publishedAt = newsDataModel.publishedAt
        
        var shouldShowImage = false
        guard let media = newsDataModel.media else { return }
        for i in 0..<media.count {
            let mediaObject = media[i]
            guard let url = mediaObject.url else { return }
            if mediaObject.type == "image" && url.count > 4 && !url.hasSuffix(".gif") {
                shouldShowImage = true
                imageURL = url
                break
            }
        }
        self.shouldShowImage = shouldShowImage
        shouldShowBookmarkImage = FavouriteManager.sharedManager.hasFavouritedNewsItem(newsDataModel)
    }
    
    
    init(with newsFavouriteDataModel: NewsFavouriteDataModel) {
        id = newsFavouriteDataModel.id ?? 0
        sourceName = newsFavouriteDataModel.source?.name ?? ""
        title = newsFavouriteDataModel.title ?? ""
        publishedAt = newsFavouriteDataModel.publishedAt
        
        var shouldShowImage = false
        guard let media = newsFavouriteDataModel.media else { return }
        for i in 0..<media.count {
            let mediaObject = media[i]
            guard let url = mediaObject.url else { return }
            if mediaObject.type == "image" && url.count > 4 && !url.hasSuffix(".gif") {
                shouldShowImage = true
                imageURL = url
                break
            }
        }
        self.shouldShowImage = shouldShowImage
        shouldShowBookmarkImage = true
    }
}
