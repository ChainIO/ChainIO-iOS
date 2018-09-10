//
//  TopicPickerLabel.swift
//  Blocain
//
//  Created by Lihao Li on 2018/9/8.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class TopicPickerLabel: UILabel {
    
    var padding: UIEdgeInsets = UIEdgeInsetsMake(12, 20, 12, 20)

    override func draw(_ rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, padding))
    }

    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var adjustSize = super.sizeThatFits(size)
        adjustSize.width += padding.left + padding.right
        adjustSize.height += padding.top + padding.bottom
        
        return adjustSize
    }
}
