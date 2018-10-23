//
//  TopicsPickerView.swift
//  Blocain
//
//  Created by Lihao Li on 2018/9/8.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

@objc protocol TopicsPickerViewDelegate {
    func tappedDoneButton()
    @objc optional func topicsDidChange()
    @objc optional func showErrorMessage()
}


class TopicsPickerView: UIView {
    
    var delegate: TopicsPickerViewDelegate?
    
    private let subTitleLabel = UILabel()
    
    var collectionView: UICollectionView!
    
    private let doneButton = BLButton()
    
    var topicDataModelArray = [TopicDataModel]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var title: String? {
        set {
            subTitleLabel.text = newValue
        }
        
        get {
            return subTitleLabel.text
        }
    }
    
    var buttonTitle: String? {
        set {
            doneButton.setTitle(newValue, for: .normal)
        }
        
        get {
            return doneButton.title(for: .normal)
        }
    }
    
    private var longPressGesture: UILongPressGestureRecognizer!
    
    var didChangeTopics = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        subTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        subTitleLabel.textAlignment = .left
        subTitleLabel.numberOfLines = 0
        addSubview(subTitleLabel)
        
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionViewFlowLayout.minimumInteritemSpacing = 12.0
        collectionViewFlowLayout.minimumLineSpacing = 20.0
        collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(5, 30, 5, 30)
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TopicsPickerCell.classForCoder(), forCellWithReuseIdentifier: TopicsPickerCell.defaultIdentifier)
        addSubview(collectionView)
        
        doneButton.setTitle("Start", for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
        doneButton.backgroundColor = UIColor(red: 74/255.0, green: 144/255.0, blue: 226/255.0, alpha: 1.0)
        doneButton.addTarget(self, action: #selector(self.tappedDoneButton), for: .touchUpInside)
        doneButton.layer.cornerRadius = 27.0
        addSubview(doneButton)
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
        
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        subTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24.0).isActive = true
        subTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10.0).isActive = true
        subTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24.0).isActive = true
        subTitleLabel.sizeToFit()
        
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0.0).isActive = true
        collectionView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 48.0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -36.0).isActive = true
        
        doneButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24.0).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24.0).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -56.0).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 54.0).isActive = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func tappedDoneButton() {
        let tmpArray = topicDataModelArray.filter(){$0.isSelected == true}
        guard tmpArray.count > 0 else {
            delegate?.showErrorMessage?()
            return
        }
        
        TopicManager.sharedManager.saveUserCustomTopics(array: topicDataModelArray)
        if didChangeTopics {
            delegate?.topicsDidChange?()
        }
        delegate?.tappedDoneButton()
    }
    
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
}


extension TopicsPickerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topicDataModelArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopicsPickerCell.defaultIdentifier, for: indexPath) as! TopicsPickerCell
        cell.setTitleLabelText(topicDataModelArray[indexPath.item].name)
        cell.isSelected = topicDataModelArray[indexPath.item].isSelected
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let title = topicDataModelArray[sourceIndexPath.item]
        topicDataModelArray.remove(at: sourceIndexPath.item)
        topicDataModelArray.insert(title, at: destinationIndexPath.item)
        didChangeTopics = true
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let topicModel = topicDataModelArray[indexPath.item]
        topicModel.isSelected = !topicModel.isSelected
        if topicModel.isSelected {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .init(rawValue: 0))
        }else {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        didChangeTopics = true
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tmpLabel = TopicPickerLabel()
        tmpLabel.text = topicDataModelArray[indexPath.item].name
        let size = tmpLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 40))
        return size
    }
    
}


class TopicsPickerCell: UICollectionViewCell {
    
    private let titleLabel = TopicPickerLabel()
    
    class var defaultIdentifier: String {
        get {
            return NSStringFromClass(self.classForCoder())
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 20.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.withAlphaComponent(0.14).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        layer.backgroundColor = UIColor.clear.cgColor
        
        titleLabel.font = UIFont.systemFont(ofSize: 14.0)
        titleLabel.textAlignment = .center
        titleLabel.preferredMaxLayoutWidth = 300
        contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
    
    override func prepareForReuse() {
        invalidateIntrinsicContentSize()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        
        set {
            if newValue {
                titleLabel.backgroundColor = UIColor(red: 80/255.0, green: 227/255.0, blue: 194/255.0, alpha: 1.0)
                titleLabel.textColor = .white
            }else {
                titleLabel.textColor = UIColor(red: 144/255.0, green: 144/255.0, blue: 144/255.0, alpha: 1.0)
                titleLabel.backgroundColor = .white
                
            }
        }
    }
    
    
    func setTitleLabelText(_ text: String) {
        titleLabel.text = text
        layoutIfNeeded()
    }

}
