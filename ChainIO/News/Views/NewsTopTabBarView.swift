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
    
    var tabBarCollectionView:UICollectionView?
    var bottomBorderLabel = UILabel()
    
    let testTitles = ["All", "Blockchain", "Bitcoin", "Eth"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
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
            tabBarCollectionView.backgroundColor = UIColor.white
            tabBarCollectionView.register(NewsTopTabBarViewCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: NewsTopTabBarViewCollectionViewCell.defaultReuseIdentifier())
            tabBarCollectionView.delegate = self
            tabBarCollectionView.dataSource = self
            addSubview(tabBarCollectionView)
        }
        
        bottomBorderLabel = UILabel()
        bottomBorderLabel.backgroundColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        self.addSubview(bottomBorderLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tabBarCollectionView?.frame = CGRect(x: 0, y: constants.tabBarCollectionViewTopSpace, width: bounds.width, height: bounds.height - constants.tabBarCollectionViewTopSpace)
        
        bottomBorderLabel.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
    }
    
    
    // MARK:
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return testTitles.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsTopTabBarViewCollectionViewCell.defaultReuseIdentifier(), for: indexPath) as! NewsTopTabBarViewCollectionViewCell
        cell.setTitleLabelText(testTitles[indexPath.row])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = self.testTitles[indexPath.row].size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13.0, weight: .semibold)])
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
        titleLabel.backgroundColor = UIColor.white
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
        return NSStringFromClass(self.classForCoder())
    }
    
    
    func setTitleLabelText(_ text: String) {
        titleLabel.text = text
        self.setNeedsLayout()
    }
}
