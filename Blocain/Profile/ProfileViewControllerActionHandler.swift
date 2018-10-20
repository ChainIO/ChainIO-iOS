//
//  ProfileViewControllerActionHandler.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/8/3.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

protocol ProfileViewControllerActionHandlerProtocol {
     func actionHandlerDidTapCell(at index: Int)
}


protocol ProfileViewControllerActionHandlerDelegate {
    func profileActionHandlerDidTapCell(at index: Int)
}


struct ProfileViewControllerActionHandler: ProfileViewControllerActionHandlerProtocol {
    var delegate: ProfileViewControllerActionHandlerDelegate?
    
    func actionHandlerDidTapCell(at index: Int) {
        delegate?.profileActionHandlerDidTapCell(at: index)
    }
}
