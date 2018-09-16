//
//  OnboardingViewControllerContentProvider.swift
//  Blocain
//
//  Created by Lihao Li on 2018/9/10.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

protocol OnboardingViewControllerContentProtocol {
    var topicDataModelArray: [TopicDataModel] {set get}
}

protocol OnboardingViewControllerContentProviderProtocol: CIContentProviderProtocol {
    var content: OnboardingViewControllerContentProtocol {get}
    
    func tappedActionButton()
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
        guard let processingQueue = self.processingQueue else { return }
        
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
    
    
    func tappedActionButton() {
        delegate?.onboardingViewControllerTappedActionButton()
    }
}
