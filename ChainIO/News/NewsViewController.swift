//
//  NewsViewController.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/24.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController {
    var contentProvider: NewsViewControllerContentProvider?
    var actionHandler: NewsViewControllerActionHandler?
    
    
    init(contentProvider: NewsViewControllerContentProvider, actionHandler: NewsViewControllerActionHandler) {
        self.contentProvider = contentProvider
        self.actionHandler = actionHandler
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.yellow
    }
}
