//
//  AppDelegate+App.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/24.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit
import FirebaseFirestore
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
        checkAppVersion()
    }
    
    
    private func checkAppVersion() {
        if let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            let versionNumberArray = versionNumber.components(separatedBy: ".")
            var versionValue = 0
            for num in versionNumberArray {
                if let value = Int(num) {
                    versionValue = versionValue * 10 + value
                }
            }
            getMinimum(versionNumber: versionValue)
        }
    }
    
    
    private func getMinimum(versionNumber: Int) {
        let processingQueue = DispatchQueue(label: "com.blocain.processingQueue2", qos: .userInteractive, attributes: [.concurrent], autoreleaseFrequency: .inherit, target: nil)
        
        let firestore = CIFirestore.sharedInstance
        firestore.waitForConfigureWith(completionQueue: processingQueue, completion: {
            Firestore.firestore().document("/MinimumVersion/kErK3Qgzx6AJbhaXLZb0").getDocument(completion: { (snapshot, error) in
                guard let snapshot = snapshot, error == nil else {
                    return
                }
                
                if let data: [String: Any] = snapshot.data() {
                    if let minimumVersion = data["version"] as? Int {
                        if versionNumber < minimumVersion {
                            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
                            alertWindow.rootViewController = UIViewController()
                            alertWindow.windowLevel = UIWindowLevelAlert + 1
                            
                            let alertViewController = UIAlertController(title: "Error", message: "Please go to the app store download the latest version of our app", preferredStyle: .alert)
                            alertWindow.makeKeyAndVisible()
                            alertWindow.rootViewController?.present(alertViewController, animated: true, completion: nil)
                        }
                    }
                }
            })
        })
    }
    
    
    private func showOnboardingViewController() {
        let onboardingViewControllerContentProvider = OnboardingViewControllerContentProvider()
        onboardingViewControllerContentProvider.delegate = self
        let onboardingViewController = OnboardingViewController(contentProvider: onboardingViewControllerContentProvider)
        self.window?.rootViewController = onboardingViewController
    }
    
    
    private func showNewsViewController() {
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
