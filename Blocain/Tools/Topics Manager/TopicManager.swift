//
//  TopicManager.swift
//  Blocain
//
//  Created by Lihao Li on 2018/9/10.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseDatabase

struct TopicDataModel {
    let name: String
    var index: Int
    var isDefaultSelected: Bool
    let query: String
}


class TopicManager: NSObject {
    static let sharedManager = TopicManager()
    
    private(set) var topicDataModelArray: [TopicDataModel]
    
    private override init() {
        topicDataModelArray = [TopicDataModel]()
    }
    
    func fetchTopicsDataModels(processingQueue: DispatchQueue, completion: @escaping ([TopicDataModel]?, Error?) -> Void) {
        let firestore = CIFirestore.sharedInstance
        firestore.waitForConfigureWith(completionQueue: processingQueue) {
            Firestore.firestore().document("/TopicsList/7oXjtIUidN5lSMj6m21E").getDocument(completion: { (snapshot, error) in
                guard let snapshot = snapshot, error == nil else {
                    completion(nil, error)
                    return
                }
                
                if let data: [String: Any] = snapshot.data() {
                    if let dataArray = data["Topics"] as? [AnyObject] {
                        for data in dataArray {
                            let topicDataModel = TopicDataModel(name: data.object(forKey: "name") as! String, index: data.object(forKey: "index") as! Int, isDefaultSelected: data.object(forKey: "isDefaultSelected") as! Bool, query: data.object(forKey: "query") as! String)
                            self.topicDataModelArray.append(topicDataModel)
                        }
                        self.topicDataModelArray.sort(){$0.index < $1.index}
                        completion(self.topicDataModelArray, nil)
                    }
                }
                

            })
        }
    }
}
