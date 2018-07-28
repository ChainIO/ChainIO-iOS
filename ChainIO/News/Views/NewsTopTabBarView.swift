//
//  NewsTopTabBarView.swift
//  ChainIO
//
//  Created by 李立昊 on 2018/7/27.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class NewsTopTabBarView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    enum NewsTopTabBarViewConstant {
        static let tabBarCollectionViewFlowLayoutSpace:CGFloat = 14.0
        static let tabBarCollectionViewTopSpace:CGFloat = 20.0
    }
    typealias constants = NewsTopTabBarViewConstant
    
    var tabBarSelectedIndex = 0
    
    var tabBarCollectionView:UICollectionView?
    let tabBarSelectedIndexBottomIndicator = UILabel()
    let bottomBorderLabel = UILabel()
    
    var items: [String] = [String]() {
        didSet {
            tabBarCollectionView?.reloadData()
            tabBarCollectionView?.selectItem(at: IndexPath(row: tabBarSelectedIndex, section: 0), animated: false, scrollPosition: .init(rawValue: 0))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let tabBarCollectionViewFlowLayout = UICollectionViewFlowLayout()
        tabBarCollectionViewFlowLayout.minimumInteritemSpacing = constants.tabBarCollectionViewFlowLayoutSpace
        tabBarCollectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(0, constants.tabBarCollectionViewFlowLayoutSpace, 0, constants.tabBarCollectionViewFlowLayoutSpace)
        tabBarCollectionViewFlowLayout.scrollDirection = .horizontal
        
        tabBarCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: tabBarCollectionViewFlowLayout)
        if let tabBarCollectionView = tabBarCollectionView {
            if #available(iOS 11.0, *) {
                tabBarCollectionView.contentInsetAdjustmentBehavior = .never
            }
            tabBarCollectionView.showsVerticalScrollIndicator = false
            tabBarCollectionView.showsHorizontalScrollIndicator = false
            tabBarCollectionView.alwaysBounceHorizontal = true
            tabBarCollectionView.backgroundColor = .white
            tabBarCollectionView.register(NewsTopTabBarViewCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: NewsTopTabBarViewCollectionViewCell.defaultReuseIdentifier())
            tabBarCollectionView.delegate = self
            tabBarCollectionView.dataSource = self
            addSubview(tabBarCollectionView)
            
            tabBarSelectedIndexBottomIndicator.backgroundColor = .black
            tabBarSelectedIndexBottomIndicator.layer.cornerRadius = 0.5
            tabBarCollectionView.addSubview(tabBarSelectedIndexBottomIndicator)
        }
        
        bottomBorderLabel.backgroundColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        addSubview(bottomBorderLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tabBarCollectionView?.frame = CGRect(x: 0, y: constants.tabBarCollectionViewTopSpace, width: bounds.width, height: bounds.height - constants.tabBarCollectionViewTopSpace)
        
        bottomBorderLabel.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
        
        layoutTabBarSelectedIndexBottomIndicator()
    }
    
    
    private func layoutTabBarSelectedIndexBottomIndicator() {
        guard let tabBarCollectionView = tabBarCollectionView else {
            return
        }
        
        let indexPathForSelectedTab = IndexPath(row: tabBarSelectedIndex, section: 0)
        if tabBarCollectionView.cellForItem(at: indexPathForSelectedTab) != nil {
            guard let selectedTabFrame = tabFrameInSuperView(indexPathForSelectedTab) else {
                return
            }
            tabBarSelectedIndexBottomIndicator.frame = CGRect(x: selectedTabFrame.origin.x, y: tabBarCollectionView.bounds.height - 3, width: selectedTabFrame.width, height: 3)
        }
    }
    
    
    private func tabFrameInSuperView(_ indexPath: IndexPath) -> CGRect? {
        guard let tabBarCollectionView = tabBarCollectionView else {
            return .zero
        }
        let attributes = tabBarCollectionView.layoutAttributesForItem(at: indexPath)
        guard let tabRect = attributes?.frame else {
            return .zero
        }
        let tabFrame = tabBarCollectionView.convert(tabRect, to: tabBarCollectionView)
        return tabFrame
    }
    
    
    private func tabBarBottomIndexIndicatorScrollTo(_ indexPath: IndexPath, animate: Bool) {
        if let selectedTabFrame = tabFrameInSuperView(indexPath) {
            UIView.animate(withDuration: 0.15, animations: {
                self.tabBarSelectedIndexBottomIndicator.frame = CGRect(x: selectedTabFrame.origin.x, y: (self.tabBarCollectionView?.bounds.height)! - 3, width: selectedTabFrame.width, height: 3)
            }, completion: nil)
        }
    }
    
    
    // MARK: UICollectionView
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsTopTabBarViewCollectionViewCell.defaultReuseIdentifier(), for: indexPath) as! NewsTopTabBarViewCollectionViewCell
        cell.setTitleLabelText(items[indexPath.row])
        cell.isSelected = (indexPath.row == tabBarSelectedIndex)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tabBarSelectedIndex = indexPath.row
        tabBarBottomIndexIndicatorScrollTo(indexPath, animate: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = items[indexPath.row].size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13.0, weight: .semibold)])
        size.height = bounds.size.height - constants.tabBarCollectionViewTopSpace
        return size
    }
}


class NewsTopTabBarViewCollectionViewCell: UICollectionViewCell {
    
    private let titleLabel = UILabel()
    
    override var isSelected: Bool {
        didSet {
            titleLabel.textColor = UIColor.init(white: 0 / 255.0, alpha: isSelected ? 1.0 : 0.4)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = UIColor.darkGray
        titleLabel.backgroundColor = .clear
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = CGRect(x: 0, y: 35, width: contentView.bounds.width, height: 18)
    }
    
    
    class func defaultReuseIdentifier() -> String {
        return NSStringFromClass(classForCoder())
    }
    
    
    func setTitleLabelText(_ text: String) {
        titleLabel.text = text
        setNeedsLayout()
    }
}
