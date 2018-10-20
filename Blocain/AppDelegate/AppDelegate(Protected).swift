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
        static var tabBarNavigationController = UINavigationController()
        static var newsViewControllerContentProvider = NewsViewControllerContentProvider()
        static var newsViewController = NewsViewController()
        static var profileViewControllerContentProvider = ProfileViewControllerContentProvider()
        static var profileViewController = ProfileViewController()
    }
    
    var tabBarNavigationController: UINavigationController {
        get {
            return AppDelegateProtected.tabBarNavigationController
        }
        set(newValue) {
            AppDelegateProtected.tabBarNavigationController = newValue
        }
    }
    
    var newsViewController: NewsViewController {
        get {
            return AppDelegateProtected.newsViewController
        }
        set(newValue) {
            AppDelegateProtected.newsViewController = newValue
        }
    }
    
    var newsViewControllerContentProvider: NewsViewControllerContentProvider {
        get {
            return AppDelegateProtected.newsViewControllerContentProvider
        }
        set(newValue) {
            AppDelegateProtected.newsViewControllerContentProvider = newValue
        }
    }
    
    var profileViewController: ProfileViewController {
        get {
            return AppDelegateProtected.profileViewController
        }
        set(newValue) {
            AppDelegateProtected.profileViewController = newValue
        }
    }
    
    var profileViewControllerContentProvider: ProfileViewControllerContentProvider {
        get {
            return AppDelegateProtected.profileViewControllerContentProvider
        }
        set(newValue) {
            AppDelegateProtected.profileViewControllerContentProvider = newValue
        }
    }
}
