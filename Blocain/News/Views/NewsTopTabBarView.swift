//
//  NewsTopTabBarView.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/27.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

protocol NewsTopTabBarViewDelegate: AnyObject {
    func didSelectIndex(_ index: Int)
    func tappedFilterButton()
}


class NewsTopTabBarView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    enum NewsTopTabBarViewConstant {
        static let tabBarCollectionViewFlowLayoutSpace:CGFloat = 14.0
        static let tabBarCollectionViewTopSpace:CGFloat = 20.0
    }
    typealias constants = NewsTopTabBarViewConstant
    
    var tabBarSelectedIndex = 0
    
    weak var delegate:NewsTopTabBarViewDelegate?
    
    private var tabBarCollectionView:UICollectionView?
    private let tabBarSelectedIndexBottomIndicator = UILabel()
    private let bottomBorderLabel = UILabel()
    private let filterButton = BLButton()
    
    var items: [String] = [String]() {
        didSet {
            tabBarCollectionView?.reloadData()
            tabBarCollectionView?.layoutIfNeeded()
            tabBarCollectionView?.selectItem(at: IndexPath(item: tabBarSelectedIndex, section: 0), animated: false, scrollPosition: .init(rawValue: 0))
            layoutTabBarSelectedIndexBottomIndicator()
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
            tabBarCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 30)
            tabBarCollectionView.delegate = self
            tabBarCollectionView.dataSource = self
            addSubview(tabBarCollectionView)
            
            tabBarSelectedIndexBottomIndicator.backgroundColor = UIColor(red: 74 / 255.0, green: 144 / 255.0, blue: 226 / 255.0, alpha: 1.0)
            tabBarSelectedIndexBottomIndicator.layer.cornerRadius = 0.5
            tabBarCollectionView.addSubview(tabBarSelectedIndexBottomIndicator)
        }
        
        bottomBorderLabel.backgroundColor = UIColor(red: 118/255.0, green: 118/255.0, blue: 118/255.0, alpha: 0.08)
        bottomBorderLabel.layer.shadowColor = UIColor(red: 118/255.0, green: 118/255.0, blue: 118/255.0, alpha: 0.08).cgColor
        bottomBorderLabel.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
        layer.shadowRadius = 9.0
        layer.shadowOpacity = 1.0
        addSubview(bottomBorderLabel)
        
        filterButton.setImage(UIImage(named: "ic_filter"), for: .normal)
        filterButton.addTarget(self, action: #selector(self.tappedFilterButton), for: .touchUpInside)
        addSubview(filterButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tabBarCollectionView?.frame = CGRect(x: 0, y: constants.tabBarCollectionViewTopSpace, width: bounds.width, height: bounds.height - constants.tabBarCollectionViewTopSpace)
        
        bottomBorderLabel.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
        
        filterButton.frame = CGRect(x: bounds.width - (filterButton.imageView?.image?.size.width ?? 45), y: bounds.height - (filterButton.imageView?.image?.size.height ?? 22) - 14, width: filterButton.imageView?.image?.size.width ?? 45, height: filterButton.imageView?.image?.size.height ?? 22)
        
        layoutTabBarSelectedIndexBottomIndicator()
    }
    
    
    @objc private func tappedFilterButton() {
        delegate?.tappedFilterButton()
    }
    
    
    func setSelectedIndex(_ selectedIndex: Int) {
        tabBarSelectedIndex = selectedIndex
        let index = IndexPath(item: selectedIndex, section: 0)
        if tabFrameInWindow(index) == nil {
            tabBarCollectionView?.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        }
        
        if let cellFrame = tabFrameInWindow(index) {
            if cellFrame.width + cellFrame.origin.x > self.bounds.width - 30 || cellFrame.origin.x < 20 {
                tabBarCollectionView?.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            }
            tabBarCollectionView?.selectItem(at: index, animated: false, scrollPosition: .init(rawValue: 0))
        }
        tabBarBottomIndexIndicatorScrollTo(index, animate: true)
    }
    
    
    private func tabBarBottomIndexIndicatorScrollTo(_ indexPath: IndexPath, animate: Bool) {
        if let selectedTabFrame = tabFrameInSuperView(indexPath) {
            UIView.animate(withDuration: 0.15, animations: {
                self.tabBarSelectedIndexBottomIndicator.frame = CGRect(x: selectedTabFrame.origin.x, y: (self.tabBarCollectionView?.bounds.height)! - 3, width: selectedTabFrame.width, height: 3)
            }, completion: nil)
        }
    }
    
    
    private func layoutTabBarSelectedIndexBottomIndicator() {
        guard let tabBarCollectionView = tabBarCollectionView else {
            return
        }
        
        let indexPathForSelectedTab = IndexPath(item: tabBarSelectedIndex, section: 0)
        if tabBarCollectionView.cellForItem(at: indexPathForSelectedTab) != nil {
            guard let selectedTabFrame = tabFrameInSuperView(indexPathForSelectedTab) else {
                return
            }
            tabBarSelectedIndexBottomIndicator.frame = CGRect(x: selectedTabFrame.origin.x, y: tabBarCollectionView.bounds.height - 3, width: selectedTabFrame.width, height: 3)
        }
    }
    
    
    private func tabFrameInWindow(_ indexPath: IndexPath) -> CGRect? {
        guard let tabBarCollectionView = tabBarCollectionView else {
            return nil
        }
        
        guard let _ = tabBarCollectionView.cellForItem(at: indexPath) else {
            return nil
        }
        
        let attributes = tabBarCollectionView.layoutAttributesForItem(at: indexPath)
        guard let tabRect = attributes?.frame else {
            return nil
        }
        
        let tabFrame = tabBarCollectionView.convert(tabRect, to: self)
        return tabFrame
    }
    
    
    private func tabFrameInSuperView(_ indexPath: IndexPath) -> CGRect? {
        guard let tabBarCollectionView = tabBarCollectionView else {
            return nil
        }
        
        guard let _ = tabBarCollectionView.cellForItem(at: indexPath) else {
            return nil
        }
        
        let attributes = tabBarCollectionView.layoutAttributesForItem(at: indexPath)
        guard let tabRect = attributes?.frame else {
            return nil
        }
        
        let tabFrame = tabBarCollectionView.convert(tabRect, to: tabBarCollectionView)
        return tabFrame
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
        cell.setTitleLabelText(items[indexPath.item])
        cell.isSelected = (indexPath.item == tabBarSelectedIndex)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tabBarSelectedIndex = indexPath.item
        tabBarBottomIndexIndicatorScrollTo(indexPath, animate: true)
        delegate?.didSelectIndex(indexPath.item)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = items[indexPath.item].size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0, weight: .semibold)])
        size.height = bounds.size.height - constants.tabBarCollectionViewTopSpace
        return size
    }
}


class NewsTopTabBarViewCollectionViewCell: UICollectionViewCell {
    
    private let titleLabel = UILabel()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                titleLabel.textColor = UIColor(red: 74.0 / 255.0, green: 144.0 / 255.0, blue: 226 / 255.0, alpha: 1.0)
            }else {
                titleLabel.textColor = UIColor(red: 75.0 / 255.0, green: 85.0 / 255.0, blue: 89 / 255.0, alpha: 1.0)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = UIColor.darkGray
        titleLabel.backgroundColor = .clear
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = CGRect(x: 0, y: 31, width: contentView.bounds.width, height: 18)
    }
    
    
    class func defaultReuseIdentifier() -> String {
        return NSStringFromClass(classForCoder())
    }
    
    
    func setTitleLabelText(_ text: String) {
        titleLabel.text = text
        setNeedsLayout()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
