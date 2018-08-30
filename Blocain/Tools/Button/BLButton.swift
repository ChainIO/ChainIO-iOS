//
//  BLButton.swift
//  Blocain
//
//  Created by Lihao Li on 2018/8/26.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class BLButton: UIButton {
    
    private enum BLButtonConstant {
        static let defaultMinimumHitDistance = 44.0
    }
    
    private var hitTestInsets: UIEdgeInsets?
    private var hitTestFrame: CGRect?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isExclusiveTouch = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateHitTestFrame()
    }
    
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let hitTestFrame = hitTestFrame {
            return hitTestFrame.contains(point)
        }
        return true
    }
    
    
    private func updateHitTestFrame() {
        adjustHitTestInsetsToFitMinimumHitSize(minimumHitSize: CGSize(width: BLButtonConstant.defaultMinimumHitDistance, height: BLButtonConstant.defaultMinimumHitDistance))
        if let hitTestInsets = self.hitTestInsets {
            self.hitTestFrame = UIEdgeInsetsInsetRect(self.bounds, hitTestInsets)
        }
    }
    
    
    func adjustHitTestInsetsToFitMinimumHitSize(minimumHitSize: CGSize) {
        let bounds = self.bounds
        let leftRightInset = -max(0, (minimumHitSize.width - bounds.width) / 2.0)
        let topBottomInset = -max(0, (minimumHitSize.height - bounds.height) / 2.0)
        self.hitTestInsets = UIEdgeInsetsMake(topBottomInset, leftRightInset, topBottomInset, leftRightInset)
    }
    
}
