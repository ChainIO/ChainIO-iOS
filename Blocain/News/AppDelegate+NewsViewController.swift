//
//  AppDelegate+NewsViewController.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/25.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

extension AppDelegate: NewsViewControllerActionHandlerDelegate {
    func actionHandlerDidTapCell(at index: Int) {
        let newsDetailViewController = NewsDetailViewController()
        self.tabBarNavigationController.pushViewController(newsDetailViewController, animated: true)
    }
}
