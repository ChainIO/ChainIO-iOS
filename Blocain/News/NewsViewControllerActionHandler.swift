//
//  NewsViewControllerActionHandler.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/25.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

protocol NewsViewControllerActionHandlerProtocol {
    func actionHandlerDidTapCell(at index: Int)
}

protocol NewsViewControllerActionHandlerDelegate {
    func actionHandlerDidTapCell(at index: Int)
}

struct NewsViewControllerActionHandler: NewsViewControllerActionHandlerProtocol {
    var delegate: NewsViewControllerActionHandlerDelegate?
    
    func actionHandlerDidTapCell(at index: Int) {
        delegate?.actionHandlerDidTapCell(at: index)
    }
}
