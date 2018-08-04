//
//  AppDelegate+App.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/24.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

extension AppDelegate {
    func didFinishLaunchingForApp() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        self.window = window
        
        var tabBarItem = UITabBarItem()
        tabBarItem.image = UIImage(named: "tab_home")
        tabBarItem.selectedImage = UIImage(named: "tab_home")
        let homeViewController = HomeViewController()
        homeViewController.tabBarItem = tabBarItem
        
        tabBarItem = UITabBarItem()
        tabBarItem.image = UIImage(named: "tab_news")
        tabBarItem.selectedImage = UIImage(named: "tab_news")
        
        let newsViewControllerContentProvider = NewsViewControllerContentProvider()
        var newsViewControllerActionHandler = NewsViewControllerActionHandler()
        newsViewControllerActionHandler.delegate = self
        let newsViewController = NewsViewController(contentProvider: newsViewControllerContentProvider, actionHandler: newsViewControllerActionHandler)
        newsViewController.tabBarItem = tabBarItem
        
        tabBarItem = UITabBarItem()
        tabBarItem.image = UIImage(named: "tab_profile")
        tabBarItem.selectedImage = UIImage(named: "tab_profile")
        
        let profileViewControllerContentProvider = ProfileViewControllerContentProvider()
        var profileViewControllerActionHandler = ProfileViewControllerActionHandler()
        profileViewControllerActionHandler.delegate = self
        let profileViewController = ProfileViewController(contentProvider: profileViewControllerContentProvider, actionHandler: profileViewControllerActionHandler)
        profileViewController.tabBarItem = tabBarItem
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [homeViewController, newsViewController, profileViewController]
        tabBarController.selectedIndex = 1
        
        self.window?.rootViewController = tabBarController
    }
}


