//
//  NewsViewControllerActionHandler.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/25.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

protocol NewsViewControllerActionHandlerDelegate: class {
    
}

class NewsViewControllerActionHandler: NSObject {
    weak var delegate: NewsViewControllerActionHandlerDelegate?
}
