//
//  ProfileViewController.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/24.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    var contentProvider: ProfileViewControllerContentProviderProtocol?
    var actionHandler: ProfileViewControllerActionHandlerProtocol?
    
    
    init(contentProvider: ProfileViewControllerContentProviderProtocol, actionHandler: ProfileViewControllerActionHandlerProtocol) {
        self.contentProvider = contentProvider
        self.actionHandler = actionHandler
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.green
    }

}
