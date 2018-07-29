//
//  NewsViewController.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/24.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    enum NewsViewControllerConstant {
        static let topTabBarViewHeight:CGFloat = 85.0
    }
    
    var contentProvider: NewsViewControllerContentProvider?
    var actionHandler: NewsViewControllerActionHandler?
    
    let topTabBarView = NewsTopTabBarView()
    var containerCollectionView:UICollectionView?
    
    let items = ["All", "Blockchain", "Bitcoin", "Ethereum", "Ripple", "Litecoin", "Coinbase", "Robinhood"]
    
    init(contentProvider: NewsViewControllerContentProvider, actionHandler: NewsViewControllerActionHandler) {
        self.contentProvider = contentProvider
        self.actionHandler = actionHandler
        
        super.init(nibName: nil, bundle: nil)
    }
    
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        view.addSubview(topTabBarView)
        
        //Hard code now, will remove these later
        topTabBarView.items = items
        
        let containerCollectionViewFlowLayout = UICollectionViewFlowLayout()
        containerCollectionViewFlowLayout.minimumLineSpacing = 0
        containerCollectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
        containerCollectionViewFlowLayout.scrollDirection = .horizontal
        
        containerCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: containerCollectionViewFlowLayout)
        if let containerCollectionView = containerCollectionView {
            if #available(iOS 11.0, *) {
                containerCollectionView.contentInsetAdjustmentBehavior = .never
            }
            containerCollectionView.showsVerticalScrollIndicator = false
            containerCollectionView.showsHorizontalScrollIndicator = false
            containerCollectionView.alwaysBounceHorizontal = true
            containerCollectionView.isPagingEnabled = true
            containerCollectionView.backgroundColor = .white
            containerCollectionView.delegate = self
            containerCollectionView.dataSource = self
            containerCollectionView.register(NewsContainerCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: NewsContainerCollectionViewCell.defaultReuseIdentifier())
            view.addSubview(containerCollectionView)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        topTabBarView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: NewsViewControllerConstant.topTabBarViewHeight)
        
        containerCollectionView?.frame = CGRect(x: 0, y: topTabBarView.frame.maxY, width: view.bounds.width, height: view.bounds.height)
    }
    
    
    // MARK: UICollectionView
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsContainerCollectionViewCell.defaultReuseIdentifier(), for: indexPath) as! NewsContainerCollectionViewCell
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}


class NewsContainerCollectionViewCell: UICollectionViewCell {
    
    let newsTableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(newsTableView)
        
        newsTableView.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(256)) / 255.0, green: CGFloat(arc4random_uniform(256)) / 255.0, blue: CGFloat(arc4random_uniform(256)) / 255.0, alpha: 1.0)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        newsTableView.frame = contentView.frame
    }
    
    
    class func defaultReuseIdentifier() -> String {
        return NSStringFromClass(classForCoder())
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
