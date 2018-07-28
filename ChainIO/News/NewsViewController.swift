//
//  NewsViewController.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/24.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController {
    
    enum NewsViewControllerConstant {
        static let topTabBarViewHeight:CGFloat = 85.0
    }
    
    var contentProvider: NewsViewControllerContentProvider?
    var actionHandler: NewsViewControllerActionHandler?
    
    var topTabBarView = NewsTopTabBarView()
    
    init(contentProvider: NewsViewControllerContentProvider, actionHandler: NewsViewControllerActionHandler) {
        self.contentProvider = contentProvider
        self.actionHandler = actionHandler
        
        super.init(nibName: nil, bundle: nil)
    }
    
    
    override func loadView() {
        super.loadView()
        
        let topTabBarView = NewsTopTabBarView()
        view.addSubview(topTabBarView)
        self.topTabBarView = topTabBarView
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.yellow
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        topTabBarView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: NewsViewControllerConstant.topTabBarViewHeight)
    }
}
