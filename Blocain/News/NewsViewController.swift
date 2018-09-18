//
//  NewsViewController.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/24.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, NewsTopTabBarViewDelegate, CIContentProviderListener, NewsTopicsPickerViewDelegate {
    private enum NewsViewControllerConstant {
        static let topTabBarViewHeight:CGFloat = 85.0
        static let bottomTabBarHeight:CGFloat = 49.0
    }
    
    private var contentProvider: NewsViewControllerContentProviderProtocol?
    private var actionHandler: NewsViewControllerActionHandlerProtocol?
    
    private let topTabBarView = NewsTopTabBarView()
    
    private var containerCollectionView:UICollectionView?
    
    private let newsTopicPickerView = NewsTopicsPickerView()
    
    private var isShowingTopicsPickerView = false
    private var isShowingAlertView = false
    
    var containerCollectionViewCurrentPage = 0
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    
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
        
        newsTopicPickerView.delegate = self
        
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
            containerCollectionView?.frame = CGRect(x: 0, y: topTabBarView.frame.maxY, width: view.bounds.width, height: view.bounds.height - topTabBarView.frame.maxY - NewsViewControllerConstant.bottomTabBarHeight)
        }
        
        newsTopicPickerView.frame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: (UIApplication.shared.keyWindow?.bounds.height)! + 49)
    }
    
    
    func loadContent() {
        guard let content = self.contentProvider?.content else { return }
        
        topTabBarView.items = content.titlesArray
        newsTopicPickerView.topicsDataModelArray = content.topicsDataArray
        containerCollectionView?.reloadData()
    }
    
    
    private func updateIndex() {
        if let containerCollectionView = containerCollectionView {
            containerCollectionViewCurrentPage = Int(containerCollectionView.contentOffset.x / containerCollectionView.frame.width)
            topTabBarView.setSelectedIndex(containerCollectionViewCurrentPage)
            contentProvider?.index = containerCollectionViewCurrentPage
        }
    }
    
    
    private func topicsPickerView(shouldShow: Bool) {
        if shouldShow {
            UIApplication.shared.keyWindow!.addSubview(self.newsTopicPickerView)
            UIApplication.shared.keyWindow!.bringSubview(toFront: self.newsTopicPickerView)
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                var frame = self.newsTopicPickerView.frame
                frame.origin.y = 0
                self.newsTopicPickerView.frame = frame
                
            }, completion: nil)
        }else {
            isShowingTopicsPickerView = false
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                var frame = self.newsTopicPickerView.frame
                frame.origin.y = self.view.bounds.height
                self.newsTopicPickerView.frame = frame
            }) { (finished) in
                if finished {
                    self.newsTopicPickerView.removeFromSuperview()
                }
            }
        }
    }
    
    
    // MARK: NewsTopicsPickerViewDelegate
    
    
    func tappedEmptyArea() {
        topicsPickerView(shouldShow: false)
    }
    
    
    func tappedSaveButton() {
        topicsPickerView(shouldShow: false)
    }
    
    
    func topicsDidChange() {
        contentProvider?.refreshTopicsAndNewsItems()
    }
    
    
    func showErrorMessage() {
        if !isShowingAlertView {
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()
            alertWindow.windowLevel = UIWindowLevelAlert + 1
            
            let alertViewController = UIAlertController(title: "Error", message: "Please pick at least one topic to get started.", preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                alertViewController.dismiss(animated: true, completion: {[weak self] in
                    self?.isShowingAlertView = false
                })
            }))
            
            alertWindow.makeKeyAndVisible()
            alertWindow.rootViewController?.present(alertViewController, animated: true, completion: nil)
        }
    }
    
    
    // MARK: NewsTopTabBarViewDelegate
    
    
    func didSelectIndex(_ index: Int) {
        containerCollectionView?.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        contentProvider?.index = index
    }
    
    
    func tappedFilterButton() {
        isShowingTopicsPickerView = !isShowingTopicsPickerView
        topicsPickerView(shouldShow: isShowingTopicsPickerView)
    }
    
    
    // MARK: CIContentProviderListener
    
    
    func contentProviderDidChangeContent(_ contentProvider: CIContentProviderProtocol!) {
        if isViewLoaded {
            loadContent()
        }
    }
    
    
    func contentProviderDidAddContent(_ contentProvider: CIContentProviderProtocol!) {
        if let cell = containerCollectionView?.cellForItem(at: IndexPath(item: containerCollectionViewCurrentPage, section: 0)) as? NewsContainerCollectionViewCell {
            if let viewModels = self.contentProvider?.content.contentsViewModelDictionary[(self.contentProvider?.content.titlesArray[containerCollectionViewCurrentPage])!] {
                cell.viewModels = viewModels
                if let errorMessage = self.contentProvider?.content.topTabBarTopicsDataArray[containerCollectionViewCurrentPage].errorMessage {
                    cell.errorMessage = errorMessage
                }
            }
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
        cell.delegate = self
        if let viewModels = contentProvider?.content.contentsViewModelDictionary[(contentProvider?.content.titlesArray[indexPath.item])!] {
            cell.viewModels = viewModels
            if let errorMessage = contentProvider?.content.topTabBarTopicsDataArray[indexPath.item].errorMessage {
                cell.errorMessage = errorMessage
            }
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
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


extension NewsViewController: NewsDetailViewControllerScrollHelperListenerProtocol {
    
    func newsDetailViewControllerScrollHelper(inStream centerIndex: Int) {
        if let cell = containerCollectionView?.cellForItem(at: IndexPath(item: containerCollectionViewCurrentPage, section: 0)) as? NewsContainerCollectionViewCell {
            cell.tableViewScroll(to: centerIndex)
        }
    }
    
}


extension NewsViewController: NewsContainerCollectionViewCellDelegate {
    
    func newsContainerCollectionViewCellDidWantToRefresh(_ newsContainerCollectionViewCell: UICollectionViewCell) {
        contentProvider?.pullToRefresh()
    }
    
    
    func newsContainerCollectionViewCell(_ newsContainerCollectionViewCell: UICollectionViewCell, didWantToFavorite index: Int) {
        contentProvider?.favoriteItem(at: index)
    }
    
    
    func newsContainerCollectionViewCell(_ newsContainerCollectionViewCell: UICollectionViewCell, didWantToLoadNextPage page: Int) {
        contentProvider?.fetchNextPage()
    }
    
    
    func newsContainerCollectionViewCell(_ newsContainerCollectionViewCell: UICollectionViewCell, didTapCell index: Int) {
        actionHandler?.actionHandlerDidTapCell(at: index)
    }
    
}
