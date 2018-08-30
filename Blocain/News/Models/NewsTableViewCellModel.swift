//
//  NewsTableViewCellModel.swift
//  Blocain
//
//  Created by Lihao Li on 2018/8/20.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

protocol NewsTableViewCellModelProtocol {
    var sourceName: String {get}
    var title: String {get}
    var imageURL: String? {get}
    var publishedAt: String? {get}
    var shouldHideImage: Bool {get}
    var contentURL: String {get}
}

class NewsTableViewCellModel: NSObject, NewsTableViewCellModelProtocol {
    var sourceName: String = ""
    var title: String = ""
    var imageURL: String?
    var publishedAt: String?
    var shouldHideImage = false
    var contentURL: String = ""
    
    private override init() {
        super.init()
    }
    
    convenience init(with newsContentEntity: NewsContentEntity) {
        self.init()
        
        sourceName = newsContentEntity.source?.sourceName ?? ""
        title = newsContentEntity.title
        imageURL = newsContentEntity.urlToImage
        publishedAt = newsContentEntity.publishedAt
        contentURL = newsContentEntity.url
        
        shouldHideImage = (newsContentEntity.urlToImage == nil ? true : false)
    }
}
