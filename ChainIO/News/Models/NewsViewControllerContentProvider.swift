//
//  NewsViewControllerContentProvider.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/24.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit
import FirebaseFirestore

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
            let firestore = CIFirestore.sharedInstance
            firestore.waitForConfigureWith(completionQueue: processingQueue!, completion: {
                Firestore.firestore().document("/Topics/F4qqmZj5Dvz9ar8px9ze").getDocument(completion: { (snapshot, error) in
                    processingQueue?.async {
                        guard let snapshot = snapshot, error == nil else {
                            self?.defaultErrorBlock()
                            return
                        }
                        
                        if let data: [String: Any] = snapshot.data() {
                            if let topicArray = data["topicName"] as? [String] {
                                self?.content.titlesArray?.append(contentsOf: topicArray)
                            }
                        }
                        
                        self?.setContentOnMainThread(self?.content)
                    }
                })
            })
        }
    }
}


struct NewsViewControllerContent: NewsViewControllerContentProtocol {
    var titlesArray: [String]?
    
    init(titlesArray: [String]? = nil) {
        self.titlesArray = titlesArray == nil ? [String]() : titlesArray
    }
}
