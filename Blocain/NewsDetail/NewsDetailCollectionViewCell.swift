//
//  NewsDetailCollectionViewCell.swift
//  Blocain
//
//  Created by Lihao Li on 2018/9/1.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit
import WebKit

class NewsDetailCollectionViewCell: UICollectionViewCell {
    private enum NewsDetailCollectionViewCellConstant {
        static let webViewEstimatedProgressKeyPath = "estimatedProgress"
    }
    
    private let estimatedProgressView = UIView()
    
    class var defaultIdentifier: String {
        return NSStringFromClass(self.classForCoder())
    }
    
    var webView: WKWebView? {
        didSet {
            guard let webView = webView else {
                return
            }
            
            webView.addObserver(self, forKeyPath: NewsDetailCollectionViewCellConstant.webViewEstimatedProgressKeyPath, options: [.new, .old], context: nil)
            contentView.addSubview(webView)
            
            if webView.estimatedProgress < 1.0 {
                estimatedProgressView.isUserInteractionEnabled = false
                estimatedProgressView.backgroundColor = UIColor(red: 0xFF/22.0, green: 0x52/255.0, blue: 0x0d/255.0, alpha: 1.0)
                contentView.addSubview(estimatedProgressView)
            }
            
            layoutSubviews()
        }
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    override func prepareForReuse() {
        webView?.removeFromSuperview()
        estimatedProgressView.alpha = 1.0
        estimatedProgressView.removeFromSuperview()
        
        webView?.removeObserver(self, forKeyPath: NewsDetailCollectionViewCellConstant.webViewEstimatedProgressKeyPath)
    }

    
    override func layoutSubviews() {
        guard let webView = webView else {
            return
        }
        
        webView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
        
        estimatedProgressView.layer.removeAllAnimations()
        layoutEstimatedProgress(estimatedProgress: webView.estimatedProgress)
    }
    
    
    deinit {
        webView?.removeObserver(self, forKeyPath: NewsDetailCollectionViewCellConstant.webViewEstimatedProgressKeyPath)
    }
    
    
    private func layoutEstimatedProgress(estimatedProgress: Double) {
        let width = self.frame.width * CGFloat(estimatedProgress)
        estimatedProgressView.frame = CGRect(x: 0, y: 0, width: width, height: 1.0)
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let webView = webView else {
            return
        }
        
        if keyPath == NewsDetailCollectionViewCellConstant.webViewEstimatedProgressKeyPath {
            guard let oldEstimatedValue = change?[NSKeyValueChangeKey.oldKey] as? Double , let newsEstimatedValue = change?[NSKeyValueChangeKey.newKey] as? Double else {
                return
            }
            if newsEstimatedValue >= oldEstimatedValue {
                UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {
                    self.layoutEstimatedProgress(estimatedProgress: newsEstimatedValue)
                }) { (finished) in
                    if webView.estimatedProgress >= 1.0 {
                        UIView.animate(withDuration: 0.1, delay: 0.5, options: .beginFromCurrentState, animations: {
                            self.estimatedProgressView.alpha = 0.0
                        }, completion: { (finished) in
                            
                        })
                    }
                }
            }else {
                estimatedProgressView.layer.removeAllAnimations()
                estimatedProgressView.alpha = 1.0
                layoutEstimatedProgress(estimatedProgress: newsEstimatedValue)
            }
        }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
