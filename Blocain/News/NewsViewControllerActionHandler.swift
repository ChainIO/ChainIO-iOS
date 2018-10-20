//
//  NewsViewControllerActionHandler.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/25.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit
import Mixpanel


enum SwipeDirection:String {
    case SwipeLeft
    case SwipeRight
}


protocol NewsViewControllerActionHandlerProtocol {
    func actionHandlerDidTapCell(at index: Int)
    func actionHandlerTappedEmptyArea()
    func actionHandlerUpdatedTopics()
    mutating func actionHandlerDidTapTopic(topic: String?)
    mutating func actionHandlerDidScrollToTopic(direction: SwipeDirection, topic: String?)
}


protocol NewsViewControllerActionHandlerDelegate {
    func actionHandlerDidTapCell(at index: Int)
}


struct NewsViewControllerActionHandler: NewsViewControllerActionHandlerProtocol {
    var delegate: NewsViewControllerActionHandlerDelegate?
    private var topic: String?
   
    
    func actionHandlerDidTapCell(at index: Int) {
        delegate?.actionHandlerDidTapCell(at: index)
    }
    
    
    func actionHandlerTappedEmptyArea() {
        var propertyList = Properties()
        propertyList["Exited Edit Topic Screen"] = true
        propertyList["Clicked Save"] = false
        propertyList["Topic List Updated"] = false
        
        AnalyticManager.sharedManager.trackEvent(with: "Clicked Edit Topic", propertiesList: propertyList)
        
        
        let selectedTopicDataModelArray = TopicManager.sharedManager.topicDataModelArray.filter { $0.isSelected == true }
        let topicList = selectedTopicDataModelArray.map { $0.name }
        AnalyticManager.sharedManager.setPeopleProperties(property: "Number of Topics Selected", value: selectedTopicDataModelArray.count)
        AnalyticManager.sharedManager.setPeopleProperties(property: "Topic Selection List", value: topicList)
    }
    
    
    func actionHandlerUpdatedTopics() {
        var propertyList = Properties()
        propertyList["Exited Edit Topic Screen"] = false
        propertyList["Clicked Save"] = true
        propertyList["Topic List Updated"] = true
        
        AnalyticManager.sharedManager.trackEvent(with: "Clicked Edit Topic", propertiesList: propertyList)
        let selectedTopicDataModelArray = TopicManager.sharedManager.topicDataModelArray.filter { $0.isSelected == true }
        let topicList = selectedTopicDataModelArray.map { $0.name }
        AnalyticManager.sharedManager.setPeopleProperties(property: "Number of Topics Selected", value: selectedTopicDataModelArray.count)
        AnalyticManager.sharedManager.setPeopleProperties(property: "Topic Selection List", value: topicList)
    }
    
    
    mutating func actionHandlerDidTapTopic(topic: String?) {
        if self.topic != topic {
            var propertyList = Properties()
            propertyList["Topic Selected"] = topic
            propertyList["Topic Selected Action"] = "Click"
            AnalyticManager.sharedManager.trackEvent(with: "Clicked Topic", propertiesList: propertyList)
            
            self.topic = topic
        }
    }
    
    
    mutating func actionHandlerDidScrollToTopic(direction: SwipeDirection, topic: String?) {
        if self.topic != topic {
            var propertyList = Properties()
            propertyList["Topic Selected"] = topic
            propertyList["Topic Selected Action"] = direction.rawValue
            AnalyticManager.sharedManager.trackEvent(with: "Clicked Topic", propertiesList: propertyList)
            
            self.topic = topic
        }
    }
    
}
