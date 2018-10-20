//
//  AnalyticManager.swift
//  Blocain
//
//  Created by Lihao Li on 2018/10/10.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import Foundation

import Mixpanel


class AnalyticManager {
    static let sharedManager = AnalyticManager()
    
    private init(){}
    
    
    func initializeMixpanel() {
        Mixpanel.initialize(token: "c56e55d4d131c87697e48acf862ff92d")
        let distinctId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        Mixpanel.mainInstance().identify(distinctId: distinctId)
    }
    
    
    func trackEvent(with name: String, propertiesList: Properties) {
        Mixpanel.mainInstance().track(event: name, properties: propertiesList)
    }
    
    
    func setPeopleProperties(property: String, value: MixpanelType) {
        Mixpanel.mainInstance().people.set(property: property, to: value)
    }
    
    
    func fireEvent(with name: String) {
        Mixpanel.mainInstance().time(event: name)
    }
    
}
