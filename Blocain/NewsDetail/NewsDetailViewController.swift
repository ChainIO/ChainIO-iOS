//
//  NewsDetailViewController.swift
//  Blocain
//
//  Created by Lihao Li on 2018/8/31.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit
import Mixpanel

class NewsDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let newsDetailViewControllerManager: NewsDetailViewControllerManagerProtocol
    private var collectionView: UICollectionView?
    private var bookmarkButton: UIBarButtonItem?
    private var didTapBackButton = false
    private var didOpenFromHomePage = false
    
    init(newsDetailViewControllerManager: NewsDetailViewControllerManagerProtocol) {
        self.newsDetailViewControllerManager = newsDetailViewControllerManager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20.0, weight: .semibold)]
        self.navigationController?.navigationBar.barTintColor = .black
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.tappedBackButton))
        backButtonItem.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButtonItem
        let bookmarkButton = UIBarButtonItem(image: UIImage(named: "bookmark"), style: .plain, target: self, action: #selector(self.tappedBookmarkButton))
        bookmarkButton.tintColor = .white
        self.bookmarkButton = bookmarkButton
        self.navigationItem.rightBarButtonItem = bookmarkButton
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self;
        
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = 0
        collectionViewFlowLayout.sectionInset = .zero
        collectionViewFlowLayout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        guard let collectionView = collectionView else { return }
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(NewsDetailContainerCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: NewsDetailContainerCollectionViewCell.defaultIdentifier)
        view.addSubview(collectionView)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let collectionView = collectionView else { return }
        
        collectionView.frame = CGRect(x: 0, y: 64.0, width: view.bounds.width, height: view.bounds.height - 64.0)
        newsDetailViewControllerManager.setContentOffset(of: collectionView)
        newsDetailViewControllerManager.updateIndex(of: collectionView)
        updateBookmarkButton()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        newsDetailViewControllerManager.fireNewsOpenedEvent()
        didOpenFromHomePage = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        newsDetailViewControllerManager.fireNewsEndDisplayEvent(didOpenFromHomePage: didOpenFromHomePage)
        newsDetailViewControllerManager.trackExitedEvent(didTapBackButton: didTapBackButton)
    }
    
    
    @objc func tappedBackButton() {
        didTapBackButton = true
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func tappedBookmarkButton() {
        newsDetailViewControllerManager.didTapFavouriteButton {[weak self] (favourited) in
            guard let self = self else { return }
            self.bookmarkButton?.image = favourited ? UIImage(named: "bookmarked")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "bookmark")?.withRenderingMode(.alwaysOriginal)
        }
    }
    
    
    private func updateBookmarkButton() {
        bookmarkButton?.image = newsDetailViewControllerManager.hasFavouritedCurrentNewsItem() ? UIImage(named: "bookmarked")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "bookmark")?.withRenderingMode(.alwaysOriginal)
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.classForCoder())
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension NewsDetailViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        newsDetailViewControllerManager.fireNewsEndDisplayEvent(didOpenFromHomePage: didOpenFromHomePage)
        didOpenFromHomePage = false
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate, let collectionView = collectionView {
            newsDetailViewControllerManager.updateIndex(of: collectionView)
            newsDetailViewControllerManager.fireNewsOpenedEvent()
            updateBookmarkButton()
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let collectionView = collectionView {
            newsDetailViewControllerManager.updateIndex(of: collectionView)
            newsDetailViewControllerManager.fireNewsOpenedEvent()
            updateBookmarkButton()
        }
    }
    
}


extension NewsDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsDetailViewControllerManager.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return newsDetailViewControllerManager.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
}
