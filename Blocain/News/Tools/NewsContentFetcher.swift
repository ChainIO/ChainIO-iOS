//
//  NewsContentFetcher.swift
//  Blocain
//
//  Created by Lihao Li on 2018/8/17.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class NewsContentFetcher: NSObject {

    private enum AylienNewsContentFetcherConstant {
        static let host = "https://api.newsapi.aylien.com/api/v1/"
        static let path = "stories"
        static let appId = "92def0d0"
        static let appKey = "c3304064c90c78dc651c6dfb464021bc"
        static let publishedAtStart = "NOW-60DAYS"
        static let publishedAtEnd = "NOW"
        static let pageSize = "30"
        static let language = "en"
        static let sortBy = "recency"
        static let sourceLocationsCountry = "US"
    }
    
    static let defaultFetcher = NewsContentFetcher()
    
    private var contentFetcher = ContentFetcher.defaultFetcher
    
    
    private override init() {
    }
    
    
    func fetchAylienNewsContent(with title: String?, pageCursor: String?, processingQueue: DispatchQueue, completion: @escaping([NewsDataModel]?, String?, Bool) -> Void) {
        guard let title = title else {
            completion(nil, nil, false)
            return
        }
        
        var cursor: String?
        if let pageCursor = pageCursor {
            cursor = pageCursor.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
        }
        
        if let request = contentFetcher.request(with: .get, host: AylienNewsContentFetcherConstant.host, path: AylienNewsContentFetcherConstant.path, arguments: [
            "title": title,
            "published_at.start": AylienNewsContentFetcherConstant.publishedAtStart,
            "published_at.end": AylienNewsContentFetcherConstant.publishedAtEnd,
            "language": AylienNewsContentFetcherConstant.language,
            "source.locations.country": AylienNewsContentFetcherConstant.sourceLocationsCountry,
            "sort_by": AylienNewsContentFetcherConstant.sortBy,
            "per_page": AylienNewsContentFetcherConstant.pageSize,
            "cursor": cursor == nil ? "*" : cursor!
            ], bodyJsonObject: nil) {
            contentFetcher.fetchContent(with: request, processingQueue: processingQueue, successHandler: { (json) in
                if let storiesJsonData = json["stories"] as? [[AnyHashable: Any]] {
                    if let newsJsonData = try? JSONSerialization.data(withJSONObject: storiesJsonData, options: []) {
                        do {
                            let newsArray = try JSONDecoder().decode([NewsDataModel].self, from: newsJsonData)
                            if let nextPageCursor = json["next_page_cursor"] as? String {
                                completion(newsArray, nextPageCursor,true)
                                return
                            }
                        }catch {
                            print("Error is: \(error)")
                        }
                    }
                }
                completion(nil, nil, false)
            }) {
                completion(nil, nil, false)
            }
        }
    }

}
