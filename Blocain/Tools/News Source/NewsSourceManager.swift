
//
//  NewsSourceManager.swift
//  Blocain
//
//  Created by Lihao Li on 2018/8/20.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class NewsSourceManager: NSObject {
    static let sharedManager = NewsSourceManager()
    var newsSourceArray: [String]
    
    private override init() {
        newsSourceArray = [String]()
        
        super.init()
    }
    
    func filterContents(newsContentEntitiesArray: [NewsContentEntity]) -> ([NewsContentEntity], [NewsTableViewCellModelProtocol]) {
        let highQualityNewsContentEntities = newsContentEntitiesArray.filter({ (newsEntity) -> Bool in
            if let sourceName = newsEntity.source?.sourceName {
                return newsSourceArray.index(of: sourceName) != nil
            }
            return false
        })
        
        let highQualityNewsContentEntityViewModels: [NewsTableViewCellModelProtocol] = highQualityNewsContentEntities.map {
            return NewsTableViewCellModel(with: $0)
        }
        
        return (highQualityNewsContentEntities, highQualityNewsContentEntityViewModels)
    }
}
