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
        let currentTopicIndex = newsViewControllerContentProvider.index
        if let newsDataModelArray = self.newsViewControllerContentProvider.content.contentsDictionary[self.newsViewControllerContentProvider.content.titlesArray[currentTopicIndex]] {
            let newsDetailViewControllerManager = NewsDetailViewControllerManager(newsDataModelsArray: newsDataModelArray, indexInStream: index, topic: newsViewControllerContentProvider.content.titlesArray[currentTopicIndex])
            let newsDetailViewController = NewsDetailViewController(newsDetailViewControllerManager: newsDetailViewControllerManager)
            self.tabBarNavigationController.pushViewController(newsDetailViewController, animated: true)
        }
    }
}
