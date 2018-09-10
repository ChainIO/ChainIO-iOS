//
//  TopicsPickerView.swift
//  Blocain
//
//  Created by Lihao Li on 2018/9/8.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class TopicsPickerView: UIView {
    
    private let subTitleLabel = UILabel()
    
    private var collectionView: UICollectionView!
    
    private var topics = ["Blockchain", "Bitcoin", "Ripple", "Bitcoin Cash", "Ethereum", "Smart Contracts", "Cryptocurrency", "Litecoin", "Coinbase", "ICO", "Dapp", "Celebrities", "aaa", "bbb", "ccc", "eeee", "fff", "ggg"]
    
    private var longPressGesture: UILongPressGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        subTitleLabel.text = "Pick the topics that you would like to see and read about."
        subTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        subTitleLabel.textAlignment = .left
        subTitleLabel.numberOfLines = 0
        addSubview(subTitleLabel)
        
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionViewFlowLayout.minimumInteritemSpacing = 16.0
        collectionViewFlowLayout.minimumLineSpacing = 24.0
        collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(12, 24, 12, 40)
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TopicsPickerCell.classForCoder(), forCellWithReuseIdentifier: TopicsPickerCell.defaultIdentifier)
        addSubview(collectionView)
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
        
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        subTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24.0).isActive = true
        subTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16.0).isActive = true
        subTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24.0).isActive = true
        subTitleLabel.sizeToFit()
        
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0.0).isActive = true
        collectionView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 48.0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        return topics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopicsPickerCell.defaultIdentifier, for: indexPath) as! TopicsPickerCell
        cell.setTitleLabelText(topics[indexPath.item])
        cell.isSelected = indexPath.item % 2 == 0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let title = topics[sourceIndexPath.item]
        topics.remove(at: sourceIndexPath.item)
        topics.insert(title, at: destinationIndexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tmpLabel = TopicPickerLabel()
        tmpLabel.text = topics[indexPath.item]
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
