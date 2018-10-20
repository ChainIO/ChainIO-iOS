//
//  AppDelegate+App.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/24.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

import Mixpanel

extension AppDelegate {
    func didFinishLaunchingForApp() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        self.window = window
        
        let userDefaults = UserDefaults.standard
        let hasShownOnboarding = userDefaults.bool(forKey: "hasShownOnboarding")
        if hasShownOnboarding {
            showNewsViewController()
        }else {
            showOnboardingViewController()
        }
    }
    
    
    func showOnboardingViewController() {
        let onboardingViewControllerContentProvider = OnboardingViewControllerContentProvider()
        onboardingViewControllerContentProvider.delegate = self
        let onboardingViewController = OnboardingViewController(contentProvider: onboardingViewControllerContentProvider)
        self.window?.rootViewController = onboardingViewController
    }
    
    
    func showNewsViewController() {
        var tabBarItem = UITabBarItem()
        //        tabBarItem.image = UIImage(named: "tab_home")
        //        tabBarItem.selectedImage = UIImage(named: "tab_home")
        //        let homeViewController = HomeViewController()
        //        homeViewController.tabBarItem = tabBarItem
        
        tabBarItem = UITabBarItem()
        tabBarItem.image = UIImage(named: "tab_news")
        tabBarItem.selectedImage = UIImage(named: "tab_news")
        
        let newsViewControllerContentProvider = NewsViewControllerContentProvider()
        self.newsViewControllerContentProvider = newsViewControllerContentProvider
        var newsViewControllerActionHandler = NewsViewControllerActionHandler()
        newsViewControllerActionHandler.delegate = self
        let newsViewController = NewsViewController(contentProvider: newsViewControllerContentProvider, actionHandler: newsViewControllerActionHandler)
        self.newsViewController = newsViewController
        newsViewController.tabBarItem = tabBarItem
        
        tabBarItem = UITabBarItem()
        tabBarItem.image = UIImage(named: "tab_profile")
        tabBarItem.selectedImage = UIImage(named: "tab_profile")
        
        let profileViewControllerContentProvider = ProfileViewControllerContentProvider()
        self.profileViewControllerContentProvider = profileViewControllerContentProvider
        var profileViewControllerActionHandler = ProfileViewControllerActionHandler()
        profileViewControllerActionHandler.delegate = self
        let profileViewController = ProfileViewController(contentProvider: profileViewControllerContentProvider, actionHandler: profileViewControllerActionHandler)
        self.profileViewController = profileViewController
        profileViewController.tabBarItem = tabBarItem
        
        let tabBarController = UITabBarController()
        tabBarController.delegate = self
        tabBarController.viewControllers = [newsViewController, profileViewController]
        let tabBarNavigationController = UINavigationController(rootViewController: tabBarController)
        tabBarNavigationController.setNavigationBarHidden(true, animated: false)
        self.tabBarNavigationController = tabBarNavigationController
        self.window?.rootViewController = tabBarNavigationController
    }
}


extension AppDelegate: OnboardingViewControllerContentProviderDelegate {
    
    func onboardingViewControllerTappedActionButton() {
        showNewsViewController()
    }
    
}


extension AppDelegate: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        trackTabBarSelectedEvent(viewController: viewController)
    }
    
    
    private func trackTabBarSelectedEvent(viewController: UIViewController) {
        var propertyList = Properties()
        if viewController.isKind(of: ProfileViewController.classForCoder()) {
            propertyList["Clicked Tab Bar"] = "Profile List"
        }else {
            propertyList["Clicked Tab Bar"] = "Home"
        }
        AnalyticManager.sharedManager.trackEvent(with: "Tab Bar", propertiesList: propertyList)
    }
    
}
