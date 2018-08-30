//
//  NewsDetailViewController.swift
//  Blocain
//
//  Created by Lihao Li on 2018/8/27.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit
import WebKit

protocol NewsDetailViewDelegate {
    func newsDetailViewDidWantToDismiss()
    func newsDetailViewTappedBookmarkButton()
}

class NewsDetailView: UIView {
    
    private enum NewsDetailViewConstant {
        static let webViewEstimatedProgressKeyPath = "estimatedProgress"
    }
    
    var delegate: NewsDetailViewDelegate?
    
    private let topBar = UIView()
    private let estimatedProgressView = UIView()
    private let closeButton = BLButton()
    private let bookmarkButton = BLButton()
    private let webView = WKWebView()
    private let titleLabel = UILabel()
    
    var contentURL: String? {
        didSet {
            if let urlString = contentURL, let url = URL(string: urlString) {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
    }
    
    var title: String = ""

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        topBar.backgroundColor = .black
        addSubview(topBar)

        closeButton.backgroundColor = .white
        closeButton.addTarget(self, action: #selector(self.dissmissNewsDetailView), for: .touchUpInside)
        topBar.addSubview(closeButton)
        
        bookmarkButton.backgroundColor = .white
        bookmarkButton.addTarget(self, action: #selector(self.tappedBookmarkButton), for: .touchUpInside)
        topBar.addSubview(bookmarkButton)
        
        estimatedProgressView.isUserInteractionEnabled = false
        estimatedProgressView.backgroundColor = UIColor(red: 0xFF/22.0, green: 0x52/255.0, blue: 0x0d/255.0, alpha: 1.0)
        topBar.addSubview(estimatedProgressView)
        
        webView.addObserver(self, forKeyPath: NewsDetailViewConstant.webViewEstimatedProgressKeyPath, options: [.new, .old], context: nil)
        addSubview(webView)
        
        titleLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.dissmissNewsDetailView))
        swipeRightGesture.direction = .right
        webView.addGestureRecognizer(swipeRightGesture)
        webView.scrollView.panGestureRecognizer.require(toFail: swipeRightGesture)
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.dissmissNewsDetailView))
        swipeLeftGesture.direction = .left
        webView.addGestureRecognizer(swipeLeftGesture)
        webView.scrollView.panGestureRecognizer.require(toFail: swipeLeftGesture)
    }
    
    
    override func layoutSubviews() {
        topBar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 85.0)
        closeButton.frame = CGRect(x: self.frame.width - 22 - 10, y: 46, width: 22, height: 22)
        bookmarkButton.frame = CGRect(x: self.frame.width - 22 - 10 - 22 - 22, y: 46, width: 22, height: 22)
        estimatedProgressView.layer.removeAllAnimations()
        layoutEstimatedProgress(estimatedProgress: webView.estimatedProgress)
        
        webView.frame = CGRect(x: 0, y: topBar.frame.maxY, width: self.frame.width, height: self.frame.size.height - topBar.frame.maxY)
        
        titleLabel.text = title
        titleLabel.sizeToFit()
        titleLabel.frame.size.height = 32
        titleLabel.center = CGPoint(x: topBar.center.x, y: topBar.center.y + 10.5)
    }
    
    
    deinit {
        webView.removeObserver(self, forKeyPath: NewsDetailViewConstant.webViewEstimatedProgressKeyPath)
    }
    
    
    private func layoutEstimatedProgress(estimatedProgress: Double) {
        let width = self.frame.width * CGFloat(estimatedProgress)
        estimatedProgressView.frame = CGRect(x: 0, y: topBar.frame.maxY - 1.0, width: width, height: 1.0)
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == NewsDetailViewConstant.webViewEstimatedProgressKeyPath {
            guard let oldEstimatedValue = change?[NSKeyValueChangeKey.oldKey] as? Double , let newsEstimatedValue = change?[NSKeyValueChangeKey.newKey] as? Double else {
                return
            }
            if newsEstimatedValue >= oldEstimatedValue {
                UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {
                    self.layoutEstimatedProgress(estimatedProgress: newsEstimatedValue)
                }) { (finished) in
                    if self.webView.estimatedProgress >= 1.0 {
                        UIView.animate(withDuration: 0.1, delay: 0.5, options: .beginFromCurrentState, animations: {
                            self.estimatedProgressView.alpha = 0.0
                        }, completion: nil)
                    }
                }
            }else {
                estimatedProgressView.layer.removeAllAnimations()
                estimatedProgressView.alpha = 1.0
                layoutEstimatedProgress(estimatedProgress: newsEstimatedValue)
            }
        }
    }
    
    
    @objc func tappedBookmarkButton() {
        delegate?.newsDetailViewTappedBookmarkButton()
    }
    
    
    @objc func dissmissNewsDetailView() {
        delegate?.newsDetailViewDidWantToDismiss()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
