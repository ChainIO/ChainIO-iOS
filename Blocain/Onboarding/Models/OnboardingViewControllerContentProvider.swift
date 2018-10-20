//
//  OnboardingViewControllerContentProvider.swift
//  Blocain
//
//  Created by Lihao Li on 2018/9/10.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

import Mixpanel

enum ActionButtonType {
    case skip
    case start
}

protocol OnboardingViewControllerContentProtocol {
    var topicDataModelArray: [TopicDataModel] {set get}
}

protocol OnboardingViewControllerContentProviderProtocol: CIContentProviderProtocol {
    var content: OnboardingViewControllerContentProtocol {get}
    
    func tappedActionButton(actionButtonType: ActionButtonType)
}


protocol OnboardingViewControllerContentProviderDelegate {
    func onboardingViewControllerTappedActionButton()
}


struct OnboardingViewControllerContent: OnboardingViewControllerContentProtocol {
    var topicDataModelArray: [TopicDataModel]
    
    
    init(topicDataModelArray: [TopicDataModel]? = nil) {
        self.topicDataModelArray = topicDataModelArray == nil ? [TopicDataModel]() : topicDataModelArray!
    }
}


class OnboardingViewControllerContentProvider: CIContentProvider, OnboardingViewControllerContentProviderProtocol {
    var content: OnboardingViewControllerContentProtocol
    var delegate: OnboardingViewControllerContentProviderDelegate?
    
    override init() {
        content = OnboardingViewControllerContent()
        
        super.init()
    }
    
    
    override func refresh() {
        let processingQueue = self.processingQueue
        
        processingQueue.async{[weak self] in
            guard let strongSelf = self else { return }
            
            TopicManager.sharedManager.fetchTopicsDataModels(processingQueue: processingQueue, completion: { (topicDataModelArray, error) in
                guard let topicDataModelArray = topicDataModelArray, error == nil else { return }
                let availableTopicDataModelArray = topicDataModelArray.filter({ (topicDataModel) -> Bool in
                    return topicDataModel.isAvailable
                })
                strongSelf.content.topicDataModelArray = availableTopicDataModelArray
                strongSelf.setContentOnMainThread(strongSelf.content)
            })
        }
    }
    
    
    func tappedActionButton(actionButtonType: ActionButtonType) {
        delegate?.onboardingViewControllerTappedActionButton()
        
        trackActionEvent(actionButtonType: actionButtonType)
    }
    
    
    private func trackActionEvent(actionButtonType: ActionButtonType) {
        var propertiesList = Properties()
        
        switch actionButtonType {
        case .skip:
            propertiesList["Clicked Skip"] = true
            propertiesList["Clicked Start"] = false
            break
        case .start:
            propertiesList["Clicked Skip"] = false
            propertiesList["Clicked Start"] = true
            break
        }
        
        let selectedTopicDataModelArray = TopicManager.sharedManager.topicDataModelArray.filter { $0.isSelected == true }
        let topicList = selectedTopicDataModelArray.map { $0.name }
        propertiesList["Selected Topic List"] = topicList
        AnalyticManager.sharedManager.trackEvent(with: "News Topic Onboarding", propertiesList: propertiesList)
        AnalyticManager.sharedManager.setPeopleProperties(property: "Number of Topics Selected", value: selectedTopicDataModelArray.count)
        AnalyticManager.sharedManager.setPeopleProperties(property: "Topic Selection List", value: topicList)
    }
}
