//
//  NewsTopicsPickerView.swift
//  Blocain
//
//  Created by Lihao Li on 2018/9/13.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

protocol NewsTopicsPickerViewDelegate: AnyObject {
    func tappedEmptyArea()
    func tappedSaveButton()
    func topicsDidChange()
    func showErrorMessage()
}

class NewsTopicsPickerView: UIView, TopicsPickerViewDelegate, UIGestureRecognizerDelegate {
    weak var delegate: NewsTopicsPickerViewDelegate?
    
    private let topicsPickerView = TopicsPickerView()
    private let topPlaceHolderView = UIView()
    private let dividerLabel = UILabel()
    
    var topicsDataModelArray: [TopicDataModel] {
        didSet {
            topicsPickerView.topicDataModelArray = topicsDataModelArray
            topicsPickerView.collectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        topicsDataModelArray = [TopicDataModel]()
        
        super.init(frame: frame)
        
        backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.58)
        
        topicsPickerView.title = "Pick the topics that you would like to see and read about."
        topicsPickerView.buttonTitle = "Save"
        topicsPickerView.delegate = self
        addSubview(topicsPickerView)
        
        topPlaceHolderView.backgroundColor = .white
        topPlaceHolderView.clipsToBounds = true
        topPlaceHolderView.layer.cornerRadius = 20.0
        if #available(iOS 11.0, *) {
            topPlaceHolderView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        
        addSubview(topPlaceHolderView)
        
        dividerLabel.backgroundColor = UIColor(red: 231/255.0, green: 239/255.0, blue: 241/255.0, alpha: 1.0)
        dividerLabel.clipsToBounds = true
        dividerLabel.layer.cornerRadius = 10.0
        topPlaceHolderView.addSubview(dividerLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedEmptyArea))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topicsPickerView.frame = CGRect(x: 0, y: self.bounds.height - 495.0, width: self.bounds.width, height: 495.0)
        
        topPlaceHolderView.frame = CGRect(x: 0, y: self.bounds.height - 495.0 - 45.0, width: self.bounds.width, height: 45.0)
        
        dividerLabel.frame = CGRect(x: (topPlaceHolderView.frame.width - 63.0) / 2.0, y: 8.0, width: 63.0, height: 5.0)
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
    
    
    @objc func tappedEmptyArea() {
        self.delegate?.tappedEmptyArea()
    }
    
    
    func tappedDoneButton() {
        self.delegate?.tappedSaveButton()
    }
    
    
    func topicsDidChange() {
        self.delegate?.topicsDidChange()
    }
    
    
    func showErrorMessage() {
        self.delegate?.showErrorMessage()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
