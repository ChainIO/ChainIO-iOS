//
//  ProfileTopNavigationBarView.swift
//  ChainIO
//
//  Created by 李立昊 on 2018/8/4.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class ProfileTopNavigationBarView: UIView {
    
    private var userInfoView: UIView!
    private var profileThumbnailView: UIView!
    private var pointsView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let userInfoView = UIView()
        userInfoView.layer.cornerRadius = 3.0
        userInfoView.layer.masksToBounds = false
        self.userInfoView = userInfoView
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
