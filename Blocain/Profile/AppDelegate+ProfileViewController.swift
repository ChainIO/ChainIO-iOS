//
//  AppDelegate+ProfileViewController.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/8/4.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

extension AppDelegate: ProfileViewControllerActionHandlerDelegate {
    func profileActionHandlerDidTapCell(at index: Int) {
        let favouriteNewsDetailViewControllerManager = FavouriteNewsDetailViewControllerManager(newsFavouriteDataModelsArray: profileViewController.contentProvider?.content.newsFavouriteDataModelsArray ?? [NewsFavouriteDataModel](), indexInStream: index)
        let newsDetailViewController = FavouriteNewsDetailViewController(favouriteNewsDetailViewControllerManager: favouriteNewsDetailViewControllerManager)
        self.tabBarNavigationController.pushViewController(newsDetailViewController, animated: true)
    }
}
