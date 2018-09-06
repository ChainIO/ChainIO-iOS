
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
        
        var set = Set<NewsContentEntity>()
        let uniqueNewsContentEntities = highQualityNewsContentEntities.filter { (newsEntity) -> Bool in
            if set.contains(newsEntity) {
                return false
            }else {
                set.insert(newsEntity)
                return true
            }
        }
        
        let uniqueNewsContentEntityViewModels: [NewsTableViewCellModelProtocol] = uniqueNewsContentEntities.map {
            return NewsTableViewCellModel(with: $0)
        }
        
        return (uniqueNewsContentEntities, uniqueNewsContentEntityViewModels)
    }
}
