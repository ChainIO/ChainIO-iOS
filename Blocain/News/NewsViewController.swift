//
//  NewsViewController.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/24.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, NewsTopTabBarViewDelegate, CIContentProviderListener {
    
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
        if let titlesArray = self.contentProvider?.content.titlesArray {
            topTabBarView.items = titlesArray
        }
        
        containerCollectionView?.reloadData()
    }
    
    
    private func updateIndex() {
        if let containerCollectionView = containerCollectionView {
            containerCollectionViewCurrentPage = Int(containerCollectionView.contentOffset.x / containerCollectionView.frame.size.width)
            topTabBarView.setSelectedIndex(containerCollectionViewCurrentPage)
            contentProvider?.index = containerCollectionViewCurrentPage
        }
    }
    
    
    // MARK: NewsTopTabBarViewDelegate
    
    
    func didSelectIndex(_ index: Int) {
        containerCollectionView?.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        contentProvider?.index = index
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


extension NewsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.contentProvider?.content.titlesArray.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        contentProvider?.fetch(singleTopicAt: indexPath.item)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        updateIndex()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsContainerCollectionViewCell.defaultReuseIdentifier(), for: indexPath) as! NewsContainerCollectionViewCell
        if let newsContent = contentProvider?.content.contentsDictionary[(contentProvider?.content.titlesArray[indexPath.item])!] {
            cell.dataSource = newsContent
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    
    //MARK: NewsContainerCollectionViewCellDelegate
    
    
    func newsContainerCollectionViewCell(_ newsContainerCollectionViewCell: UICollectionViewCell, didWantToLoadNextPage page: Int) {
        
    }
    
}


extension NewsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateIndex()
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateIndex()
        }
    }
}
