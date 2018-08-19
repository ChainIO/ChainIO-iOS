//
//  ContentFetcher.swift
//  Blocain
//
//  Created by Lihao Li on 2018/8/16.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

enum NewsHttpRequest: String {
    case host = "https://newsapi.org/v2/everything?q=bitcoin&apiKey=57f652b525dd49f39745f52846df7a40"
    case apiKey = "57f652b525dd49f39745f52846df7a40"
}

enum HttpRequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

class ContentFetcher: NSObject {
    static let defaultFetcher = ContentFetcher()
    
    
    private override init() {
        super.init()
    }
    
    
    func request(with httpMethod: HttpRequestMethod, host: String, path: String?, arguments: [String: String]?, bodyJsonObject: Any?) -> URLRequest? {
        var urlString = String(host)
            
        if let path = path {
            urlString.append(path)
        }
        
        var components = URLComponents(string: urlString)
        var queryItems = [URLQueryItem]()
        
        if let arguments = arguments {
            for (key,value) in arguments {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        }
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        if let bodyJsonObject = bodyJsonObject {
            do {
                let bodyData = try JSONSerialization.data(withJSONObject: bodyJsonObject, options: .prettyPrinted)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = bodyData
            } catch {
                print(error.localizedDescription)
            }
        }
        request.cachePolicy = .reloadIgnoringCacheData
        request.timeoutInterval = 15.0
        return request
    }
    
    func fetchContent(with request: URLRequest, processingQueue: DispatchQueue, successHandler: @escaping ([AnyHashable: Any]) -> Void, errorHandler: @escaping () -> Void) {
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data, response, error) in
            processingQueue.async {
                guard error == nil, let data = data else {
                    errorHandler()
                    return
                }

                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [AnyHashable: Any]
                    successHandler(jsonObject)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
}
