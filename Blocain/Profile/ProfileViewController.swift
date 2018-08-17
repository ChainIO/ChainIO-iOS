//
//  ProfileViewController.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/24.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    enum ProfileViewControllerConstant {
        static let topNavigationViewHeight: CGFloat = 85.0
    }
    
    var contentProvider: ProfileViewControllerContentProviderProtocol?
    var actionHandler: ProfileViewControllerActionHandlerProtocol?
    
    
    init(contentProvider: ProfileViewControllerContentProviderProtocol, actionHandler: ProfileViewControllerActionHandlerProtocol) {
        super.init(nibName: nil, bundle: nil)
        
        self.contentProvider = contentProvider
        self.actionHandler = actionHandler
        
        UserManager.sharedInstance.addListener(self)
    }
    
    
    deinit {
        UserManager.sharedInstance.removeListener(self)
    }
    
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        let topNavigationView = ProfileTopNavigationView()
        topNavigationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topNavigationView)
        
        NSLayoutConstraint.activate([
            topNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topNavigationView.topAnchor.constraint(equalTo: view.topAnchor),
            topNavigationView.heightAnchor.constraint(equalToConstant: ProfileViewControllerConstant.topNavigationViewHeight)
            ])
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension ProfileViewController: UserManagerProtocol {
    
}
