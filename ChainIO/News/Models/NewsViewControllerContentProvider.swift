//
//  NewsViewControllerContentProvider.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/24.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

protocol NewsViewControllerContentProtocol {
    var titlesArray: [String]? {get set}
}


protocol NewsViewControllerContentProviderProtocol: CIContentProviderProtocol {
    var content: NewsViewControllerContentProtocol {get}
}


class NewsViewControllerContentProvider: CIContentProvider, NewsViewControllerContentProviderProtocol {
    var content: NewsViewControllerContentProtocol
    
    
    override init() {
        content = NewsViewControllerContent()
        
        super.init()
    }
    
    
    override func refresh() {
        let processingQueue = self.processingQueue
        processingQueue?.async { [weak self] in
            self?.content.titlesArray = ["All", "Bitcoin", "Blockchain", "Ethereum", "Ripple", "Litecoin", "ICO", "Coinbase"]
            self?.setContentOnMainThread(self?.content)
        }
    }
}


struct NewsViewControllerContent: NewsViewControllerContentProtocol {
    var titlesArray: [String]?
    
    init(titlesArray: [String]? = nil) {
        self.titlesArray = titlesArray
    }
}
