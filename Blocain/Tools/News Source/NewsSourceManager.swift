
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
    
    func filterHighQualityContent(newsContentEntitiesArray: [NewsContentEntity]) -> [NewsContentEntity] {
        let highQualityNewsContentEntities = newsContentEntitiesArray.filter({ (newsEntity) -> Bool in
            if let sourceName = newsEntity.source?.sourceName {
                return newsSourceArray.index(of: sourceName) != nil
            }
            return false
        })
        
        return highQualityNewsContentEntities
    }
}
