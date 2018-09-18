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

class TopicDataModel: NSObject, NSCoding {
    let name: String
    var index: Int
    var isDefaultSelected: Bool
    var query: String
    var customIndex: Int
    var isSelected: Bool
    var isAvailable: Bool
    var errorMessage: String
    
    override var hash: Int {
        return name.hashValue
    }
    
    init(name: String, index: Int, isDefaultSelected: Bool, query: String, customIndex: Int, isSelected: Bool, isAvailable: Bool, errorMessage: String) {
        self.name = name
        self.index = index
        self.isDefaultSelected = isDefaultSelected
        self.query = query
        self.customIndex = customIndex
        self.isSelected = isSelected
        self.isAvailable = isAvailable
        self.errorMessage = errorMessage
    }
    
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let index = aDecoder.decodeInteger(forKey: "index")
        let isDefaultSelected = aDecoder.decodeBool(forKey: "isDefaultSelected")
        let query = aDecoder.decodeObject(forKey: "query") as! String
        let customIndex = aDecoder.decodeInteger(forKey: "customIndex")
        let isSelected = aDecoder.decodeBool(forKey: "isSelected")
        let isAvailable = aDecoder.decodeBool(forKey: "isAvailable")
        let errorMessage = aDecoder.decodeObject(forKey: "errorMessage") as! String
        
        self.init(name: name, index: index, isDefaultSelected: isDefaultSelected, query: query, customIndex: customIndex, isSelected: isSelected, isAvailable: isAvailable, errorMessage: errorMessage)
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(index, forKey: "index")
        aCoder.encode(isDefaultSelected, forKey: "isDefaultSelected")
        aCoder.encode(query, forKey: "query")
        aCoder.encode(customIndex, forKey: "customIndex")
        aCoder.encode(isSelected, forKey: "isSelected")
        aCoder.encode(isAvailable, forKey: "isAvailable")
        aCoder.encode(errorMessage, forKey: "errorMessage")
    }
    
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? TopicDataModel else { return false }
        return object.name == name
    }
}


class TopicManager: NSObject {
    static let sharedManager = TopicManager()
    
    var topicDataModelArray: [TopicDataModel]
    private(set) var originalTopicDataModelArray: [TopicDataModel]
    
    private override init() {
        topicDataModelArray = [TopicDataModel]()
        originalTopicDataModelArray = [TopicDataModel]()
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
                        var topicDataModelArray = [TopicDataModel]()
                        for data in dataArray {
                            let topicDataModel = TopicDataModel(name: data.object(forKey: "name") as! String, index: data.object(forKey: "index") as! Int, isDefaultSelected: data.object(forKey: "isDefaultSelected") as! Bool, query: data.object(forKey: "query") as! String, customIndex: Int.max, isSelected: data.object(forKey: "isDefaultSelected") as! Bool, isAvailable: data.object(forKey: "isAvailable") as! Bool, errorMessage: data.object(forKey: "errorMessage") as! String)
                            topicDataModelArray.append(topicDataModel)
                        }
                        topicDataModelArray.sort(){$0.index < $1.index}
                        self.originalTopicDataModelArray = topicDataModelArray
                        completion(topicDataModelArray, nil)
                    }
                }
            })
        }
    }
    
    
    func fetchCombinedTopicsDataModels(processingQueue: DispatchQueue, completion: @escaping ([TopicDataModel]?, [TopicDataModel]?, [TopicDataModel]?, Error?) -> Void) {
        let localTopicDataModelArray = self.getTopicDataModelArrayFromUserDefaults()
        self.fetchTopicsDataModels(processingQueue: processingQueue) { (remoteTopicDataModelArray, error) in
            guard let remoteTopicDataModelArray = remoteTopicDataModelArray else {
                return
            }
            
            var set = Set<TopicDataModel>()
            var combinedTopicDataModelArray = [TopicDataModel]()
            localTopicDataModelArray.forEach({ (topicDataModel) in
                if remoteTopicDataModelArray.contains(topicDataModel) {
                    let remoteTopicDataModel = remoteTopicDataModelArray.filter(){$0 == topicDataModel}.first
                    topicDataModel.errorMessage = remoteTopicDataModel?.errorMessage ?? ""
                    topicDataModel.isAvailable = remoteTopicDataModel?.isAvailable ?? true
                    topicDataModel.query = remoteTopicDataModel?.query ?? ""
                    topicDataModel.isDefaultSelected = remoteTopicDataModel?.isDefaultSelected ?? true
                    set.insert(topicDataModel)
                    combinedTopicDataModelArray.append(topicDataModel)
                }
            })
            
            remoteTopicDataModelArray.forEach({ (topicDataModel) in
                if !set.contains(topicDataModel) {
                    combinedTopicDataModelArray.append(topicDataModel)
                    set.insert(topicDataModel)
                }
            })
            
            combinedTopicDataModelArray.sort(){$0.customIndex < $1.customIndex}
            completion(localTopicDataModelArray, remoteTopicDataModelArray, combinedTopicDataModelArray, error)
        }
    }
    
    
    func saveUserCustomTopics(array: [TopicDataModel]) {
        topicDataModelArray = array
        generateCustomIndex()
        saveTopicDataModelArrayToUserDefaults()
    }
    
    
    func saveOriginalTopics() {
        topicDataModelArray = originalTopicDataModelArray
        generateCustomIndex()
        saveTopicDataModelArrayToUserDefaults()
    }
    
    
    func saveTopicDataModelArrayToUserDefaults() {
        let userDefaults = UserDefaults.standard
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: topicDataModelArray)
        userDefaults.set(encodedData, forKey: "topicDataModelArray")
        userDefaults.synchronize()
    }
    
    
    func getTopicDataModelArrayFromUserDefaults() -> [TopicDataModel] {
        let userDefaults = UserDefaults.standard
        let decoded = userDefaults.object(forKey: "topicDataModelArray") as! Data
        var decodedTopicDataModelArray = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [TopicDataModel]
        decodedTopicDataModelArray.sort(){$0.customIndex < $1.customIndex}
        return decodedTopicDataModelArray
    }
    
    
    private func generateCustomIndex() {
        for i in 0..<topicDataModelArray.count {
            topicDataModelArray[i].customIndex = i
        }
    }
}
