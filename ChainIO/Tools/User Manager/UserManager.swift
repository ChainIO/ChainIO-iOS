//
//  UserManager.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/8/4.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

@objc protocol UserManagerProtocol {
}

struct UserManager {
    
    static let sharedInstance = UserManager()
    private let listenersList = NSHashTable<UserManagerProtocol>(options: NSHashTableWeakMemory)
    
    
    private init() {}
        
    
    func addListener(_ listener: UserManagerProtocol) {
        listenersList.add(listener)
    }
    
    
    func removeListener(_ listener: UserManagerProtocol) {
        listenersList.remove(listener)
    }
}
