//
//  NewsViewControllerActionHandler.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/25.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

protocol NewsViewControllerActionHandlerProtocol {
    
}

protocol NewsViewControllerActionHandlerDelegate {
    
}

struct NewsViewControllerActionHandler: NewsViewControllerActionHandlerProtocol {
    var delegate: NewsViewControllerActionHandlerDelegate?
}
