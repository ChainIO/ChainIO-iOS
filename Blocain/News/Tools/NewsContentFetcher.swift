//
//  NewsContentFetcher.swift
//  Blocain
//
//  Created by Lihao Li on 2018/8/17.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class NewsContentFetcher: NSObject {
    private enum NewsContentFetcherConstant {
        static let host = "https://newsapi.org/v2/"
        static let path = "everything"
        static let apiKey = "57f652b525dd49f39745f52846df7a40"
        static let pageSize = "100"
        static let language = "en"
        static let sortBy = "publishedAt"
    }
    
    static let defaultFetcher = NewsContentFetcher()
    
    private var contentFetcher = ContentFetcher.defaultFetcher
    
    
    private override init() {
    }
    
    
    func fetchContent(with title: String?, processingQueue: DispatchQueue, completion: @escaping ([NewsContentEntity]?, Bool) -> Void) {
        guard let title = title else {
            completion(nil, false)
            return
        }
        
        if let request = contentFetcher.request(with: .get, host: NewsContentFetcherConstant.host, path: NewsContentFetcherConstant.path, arguments: ["apiKey": NewsContentFetcherConstant.apiKey, "q": title, "language": NewsContentFetcherConstant.language, "pageSize": NewsContentFetcherConstant.pageSize, "sortBy": NewsContentFetcherConstant.sortBy], bodyJsonObject: nil) {
            contentFetcher.fetchContent(with: request, processingQueue: processingQueue, successHandler: { (json) in
                if let articlesJSONData = json["articles"] as? [[AnyHashable: Any]]{
                    if let jsonData = try? JSONSerialization.data(withJSONObject: articlesJSONData, options: []) {
                        if let articles = try? JSONDecoder().decode([NewsContentEntity].self, from: jsonData) {
                            completion(articles, true)
                            return
                        }
                    }
                }
                completion(nil, false)
            }, errorHandler: {
                completion(nil, false)
            })
            
        }
    }
}
