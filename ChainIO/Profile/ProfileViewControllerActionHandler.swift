//
//  ProfileViewControllerActionHandler.swift
//  ChainIO
//
//  Created by 李立昊 on 2018/8/3.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

protocol ProfileViewControllerActionHandlerProtocol {
    
}


protocol ProfileViewControllerActionHandlerDelegate {
    
}


struct ProfileViewControllerActionHandler: ProfileViewControllerActionHandlerProtocol {
    var delegate: ProfileViewControllerActionHandlerDelegate?
}
