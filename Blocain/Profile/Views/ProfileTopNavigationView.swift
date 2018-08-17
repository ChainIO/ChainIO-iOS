//
//  ProfileTopNavigationBarView.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/8/4.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class ProfileTopNavigationView: UIView {
    
    private var userInfoView: UIView!
    private var profileThumbnailView: UIView!
    private var pointsView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        UserManager.sharedInstance.addListener(self)
        
        backgroundColor = .white
        
        let userInfoView = UIView()
        userInfoView.layer.cornerRadius = 3.0
        userInfoView.layer.masksToBounds = false
        userInfoView.backgroundColor = .blue
        userInfoView.translatesAutoresizingMaskIntoConstraints = false
        self.userInfoView = userInfoView
        addSubview(userInfoView)
        
        NSLayoutConstraint.activate([
            userInfoView.heightAnchor.constraint(equalToConstant: 50.0),
            userInfoView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            userInfoView.widthAnchor.constraint(equalToConstant: 200.0),
            userInfoView.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
    }
    
    
    deinit {
        UserManager.sharedInstance.removeListener(self)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension ProfileTopNavigationView: UserManagerProtocol {
    
}
