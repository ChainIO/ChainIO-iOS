//
//  NewsTableViewCellViewModel.swift
//  Blocain
//
//  Created by Lihao Li on 2018/8/20.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

protocol NewsTableViewCellViewModelProtocol {
    var sourceName: String? {get}
    var title: String? {get}
    var imageURL: String? {get}
    var publishedAt: String? {get}
    var shouldShowImage: Bool {get}
    var shouldShowGif: Bool {get}
}

class NewsTableViewCellViewModel: NSObject, NewsTableViewCellViewModelProtocol {
    var sourceName: String?
    var title: String?
    var imageURL: String?
    var publishedAt: String?
    var shouldShowImage = false
    var shouldShowGif = false
    
    private override init() {
        super.init()
    }
    
    convenience init(with newsDataModel: NewsDataModel) {
        self.init()
        
        sourceName = newsDataModel.source?.name ?? ""
        title = newsDataModel.title ?? ""
        publishedAt = newsDataModel.publishedAt
        
        var shouldShowImage = false
        guard let media = newsDataModel.media else { return }
        for i in 0..<media.count {
            let mediaObject = media[i]
            guard let url = mediaObject.url else { return }
            if mediaObject.type == "image" && mediaObject.url != nil && url.count > 4 {
                shouldShowImage = true
                imageURL = url
                shouldShowGif = imageURL?.hasSuffix(".gif") ?? false
                break
            }
        }
        self.shouldShowImage = shouldShowImage
    }
}
