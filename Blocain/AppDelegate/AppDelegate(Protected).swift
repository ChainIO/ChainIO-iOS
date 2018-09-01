//
//  AppDelegate(Protected).swift
//  Blocain
//
//  Created by Lihao Li on 2018/8/31.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

extension AppDelegate {
    struct AppDelegateProtected {
        static var tabBarNavigationController: UINavigationController = UINavigationController()
    }
    
    var tabBarNavigationController: UINavigationController {
        get {
            return AppDelegateProtected.tabBarNavigationController
        }
        set(newValue) {
            AppDelegateProtected.tabBarNavigationController = newValue
        }
    }
}
