//
//  NewsViewController.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/24.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NewsTopTabBarViewDelegate, CIContentProviderListener {
    
    enum NewsViewControllerConstant {
        static let topTabBarViewHeight:CGFloat = 85.0
        static let bottomTabBarHeight:CGFloat = 49.0
    }
    
    var contentProvider: NewsViewControllerContentProviderProtocol?
    var actionHandler: NewsViewControllerActionHandlerProtocol?
    
    let topTabBarView = NewsTopTabBarView()
    var containerCollectionView:UICollectionView?
    
    var containerCollectionViewCurrentPage = 0
    
    
    init(contentProvider: NewsViewControllerContentProviderProtocol, actionHandler: NewsViewControllerActionHandlerProtocol) {
        super.init(nibName: nil, bundle: nil)
        
        self.contentProvider = contentProvider
        self.actionHandler = actionHandler
        
        contentProvider.add(self)
        contentProvider.refresh()
    }
    
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        topTabBarView.delegate = self
        view.addSubview(topTabBarView)
        
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
        
        loadContent()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        topTabBarView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: NewsViewControllerConstant.topTabBarViewHeight)
        
        if #available(iOS 11.0, *) {
            containerCollectionView?.frame = CGRect(x: 0, y: topTabBarView.frame.maxY, width: view.bounds.width, height: view.bounds.height - topTabBarView.frame.maxY - view.safeAreaInsets.bottom)
        } else {
            // Fallback on earlier versions
            containerCollectionView?.frame = CGRect(x: 0, y: topTabBarView.frame.maxY, width: view.bounds.width, height: view.bounds.height - topTabBarView.frame.maxY - NewsViewControllerConstant.bottomTabBarHeight)
        }
    }
    
    
    func loadContent() {
        topTabBarView.items = (self.contentProvider?.content.titlesArray)!
        containerCollectionView?.reloadData()
    }
    
    
    // MARK: UICollectionView
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.contentProvider?.content.titlesArray?.count)!
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsContainerCollectionViewCell.defaultReuseIdentifier(), for: indexPath) as! NewsContainerCollectionViewCell
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let containerCollectionView = containerCollectionView {
            containerCollectionViewCurrentPage = Int(containerCollectionView.contentOffset.x / containerCollectionView.frame.size.width)
            topTabBarView.setSelectedIndex(containerCollectionViewCurrentPage)
        }
    }
    
    
    // MARK: NewsTopTabBarViewDelegate
    
    
    func didSelectIndex(_ index: Int) {
        containerCollectionView?.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    
    // MARK: CIContentProviderListener
    
    
    func contentProviderDidChangeContent(_ contentProvider: CIContentProviderProtocol!) {
        if isViewLoaded {
            loadContent()
        }
    }
    
    
    func contentProviderDidError(_ contentProvider: CIContentProviderProtocol!) {
        
    }
}


class NewsContainerCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    let newsTableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(newsTableView)
        
        newsTableView.delegate = self
        newsTableView.dataSource = self
        newsTableView.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(256)) / 255.0, green: CGFloat(arc4random_uniform(256)) / 255.0, blue: CGFloat(arc4random_uniform(256)) / 255.0, alpha: 1.0)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        newsTableView.frame = contentView.frame
    }
    
    
    class func defaultReuseIdentifier() -> String {
        return NSStringFromClass(classForCoder())
    }
    
    
    // MARK: UITableView
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
