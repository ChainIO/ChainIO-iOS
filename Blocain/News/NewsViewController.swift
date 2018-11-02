//
//  NewsViewController.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/7/24.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit
import Lottie

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
    
    private let noNetworkLabel = UILabel()
    private var hasNetwork = true
    private var hasConnectitonToBackend = true
    
    var containerCollectionViewCurrentPage = 0
    
    private let spinnerAnimationView = LOTAnimationView(name: "loader")
    private var viewIsAppeared = false
    private var isLoadingData = true
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        ReachabilityManager.sharedManager.stopMonitoring()
        ReachabilityManager.sharedManager.removeListener(self)
        
        contentProvider?.remove(self)
        FavouriteManager.sharedManager.removeListener(self)
    }
    
    
    init(contentProvider: NewsViewControllerContentProviderProtocol, actionHandler: NewsViewControllerActionHandlerProtocol) {
        super.init(nibName: nil, bundle: nil)
        
        self.contentProvider = contentProvider
        self.actionHandler = actionHandler
        
        contentProvider.add(self)
        contentProvider.refresh()
        
        FavouriteManager.sharedManager.addListener(self)
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
        
        spinnerAnimationView.contentMode = .scaleAspectFill
        spinnerAnimationView.loopAnimation = true
        spinnerAnimationView.isHidden = true
        view.addSubview(spinnerAnimationView)
        updateSpinnerAnimationView()
        
        noNetworkLabel.backgroundColor = UIColor(red: 77 / 255.0, green: 77 / 255.0, blue: 77 / 255.0, alpha: 0.95)
        noNetworkLabel.text = "No Internet Connection"
        noNetworkLabel.textColor = .white
        noNetworkLabel.textAlignment = .center
        noNetworkLabel.font = UIFont.systemFont(ofSize: 14.0)
        noNetworkLabel.isHidden = true
        view.addSubview(noNetworkLabel)
        
        newsTopicPickerView.delegate = self
        
        ReachabilityManager.sharedManager.addListener(self)
        ReachabilityManager.sharedManager.startMonitoring()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let contentProvider = contentProvider else { return }
        
        guard !contentProvider.content.titlesArray.isEmpty else {
            contentProvider.refresh()
            
            return
        }
        
        let title = contentProvider.content.titlesArray[containerCollectionViewCurrentPage]
        let viewModels = contentProvider.content.contentsViewModelDictionary[title]
        if viewModels?.isEmpty ?? true {
            contentProvider.refresh()
            
            return
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewIsAppeared = true
        updateSpinnerAnimationView()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewIsAppeared = false
        updateSpinnerAnimationView()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        topTabBarView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: NewsViewControllerConstant.topTabBarViewHeight)
        
        noNetworkLabel.frame = CGRect(x: 0, y: topTabBarView.bounds.maxY, width: view.bounds.width, height: 48)
        
        spinnerAnimationView.center = view.center
        spinnerAnimationView.frame.size = CGSize(width: 200.0, height: 200.0)
        
        if #available(iOS 11.0, *) {
            containerCollectionView?.frame = CGRect(x: 0, y: topTabBarView.frame.maxY, width: view.bounds.width, height: view.bounds.height - topTabBarView.frame.maxY - view.safeAreaInsets.bottom)
        } else {
            containerCollectionView?.frame = CGRect(x: 0, y: topTabBarView.frame.maxY, width: view.bounds.width, height: view.bounds.height - topTabBarView.frame.maxY - NewsViewControllerConstant.bottomTabBarHeight)
        }
        
        newsTopicPickerView.frame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: (UIApplication.shared.keyWindow?.bounds.height)! + 49)
    }
    
    
    private func updateSpinnerAnimationView() {
        if viewIsAppeared && isLoadingData {
            spinnerAnimationView.play()
            spinnerAnimationView.isHidden = false
        }else {
            spinnerAnimationView.stop()
            spinnerAnimationView.isHidden = true
        }
    }
    
    
    func loadContent() {
        guard let content = self.contentProvider?.content else { return }
        
        topTabBarView.items = content.titlesArray
        newsTopicPickerView.topicsDataModelArray = content.topicsDataArray
        
        containerCollectionView?.reloadData()
    
        isLoadingData = false
        updateSpinnerAnimationView()
    }
    
    
    private func updateIndex() {
        if let containerCollectionView = containerCollectionView {
            let currentPage = Int(containerCollectionView.contentOffset.x / containerCollectionView.frame.width)
            if containerCollectionViewCurrentPage != currentPage {
                if contentProvider?.fetch(singleTopicAt: currentPage) ?? false {
                    isLoadingData = true
                    updateSpinnerAnimationView()
                }
                
                topTabBarView.setSelectedIndex(currentPage)
                contentProvider?.index = currentPage
                
                actionHandler?.actionHandlerDidScrollToTopic(direction: containerCollectionViewCurrentPage < currentPage ? .SwipeLeft : .SwipeRight, topic: contentProvider?.content.titlesArray[currentPage])
                containerCollectionViewCurrentPage = currentPage
            }
        }
    }
    
    
    private func updateNoNetworkLabel() {
        noNetworkLabel.isHidden = hasNetwork
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
        actionHandler?.actionHandlerTappedEmptyArea()
    }
    
    
    func tappedSaveButton() {
        topicsPickerView(shouldShow: false)
        actionHandler?.actionHandlerUpdatedTopics()
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
        
        assert(index < contentProvider?.content.titlesArray.count ?? 0, "index should within the range of title array")
        actionHandler?.actionHandlerDidTapTopic(topic: contentProvider?.content.titlesArray[index])
    }
    
    
    func tappedFilterButton() {
        isShowingTopicsPickerView = !isShowingTopicsPickerView
        topicsPickerView(shouldShow: isShowingTopicsPickerView)
    }
    
    
    // MARK: CIContentProviderListener
    
    
    func contentProviderDidChangeContent(_ contentProvider: CIContentProviderProtocol!) {
        if isViewLoaded {
            if !hasConnectitonToBackend {
                hasConnectitonToBackend = true
                updateNoNetworkLabel()
            }
            loadContent()
        }
    }
    
    
    func contentProviderDidAddContent(_ contentProvider: CIContentProviderProtocol!) {
        if !hasConnectitonToBackend {
            hasConnectitonToBackend = true
            updateNoNetworkLabel()
        }
        
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
        hasConnectitonToBackend = false
        updateNoNetworkLabel()
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


extension NewsViewController: NewsContainerCollectionViewCellDelegate {
    
    func newsContainerCollectionViewCellDidWantToRefresh(_ newsContainerCollectionViewCell: UICollectionViewCell) {
        contentProvider?.pullToRefresh()
    }
    
    
    func newsContainerCollectionViewCell(_ newsContainerCollectionViewCell: UICollectionViewCell, didWantToLoadNextPage page: Int) {
        contentProvider?.fetchNextPage()
    }
    
    
    func newsContainerCollectionViewCell(_ newsContainerCollectionViewCell: UICollectionViewCell, didTapCell index: Int) {
        actionHandler?.actionHandlerDidTapCell(at: index)
    }
    
}


extension NewsViewController: ReachabilityManagerListenerProtocol {
    func reachabilityDidChange(hasNetwork: Bool) {
        self.hasNetwork = hasNetwork
        updateNoNetworkLabel()
    }
}


extension NewsViewController: FavouriteManagerListenerProtocol {
    func didChange(favouriteNewsItemWith id: Int, isFavourited: Bool) {
        contentProvider?.didChange(favouriteNewsItemWith: id, isFavourited: isFavourited)
        if let cell = containerCollectionView?.cellForItem(at: IndexPath(item: containerCollectionViewCurrentPage, section: 0)) as? NewsContainerCollectionViewCell {
            cell.newsTableView.reloadData()
        }
    }
}
