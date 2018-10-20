//
//  FavouriteNewsDetailViewController.swift
//  Blocain
//
//  Created by Lihao Li on 2018/10/15.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class FavouriteNewsDetailViewController: UIViewController, UIGestureRecognizerDelegate {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let favouriteNewsDetailViewControllerManager: FavouriteNewsDetailViewControllerManagerProtocol
    private var collectionView: UICollectionView?
    private var bookmarkButton: UIBarButtonItem?
    
    
    init(favouriteNewsDetailViewControllerManager: FavouriteNewsDetailViewControllerManagerProtocol) {
        self.favouriteNewsDetailViewControllerManager = favouriteNewsDetailViewControllerManager
        
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
        collectionView.register(FavouriteNewsDetailContainerCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: FavouriteNewsDetailContainerCollectionViewCell.defaultIdentifier)
        view.addSubview(collectionView)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let collectionView = collectionView else { return }
        
        collectionView.frame = CGRect(x: 0, y: 64.0, width: view.bounds.width, height: view.bounds.height - 64.0)
        favouriteNewsDetailViewControllerManager.setContentOffset(of: collectionView)
        favouriteNewsDetailViewControllerManager.updateIndex(of: collectionView)
        updateBookmarkButton()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    @objc func tappedBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func tappedBookmarkButton() {
        favouriteNewsDetailViewControllerManager.didTapFavouriteButton {[weak self] (favourited) in
            guard let self = self else { return }
            self.bookmarkButton?.image = favourited ? UIImage(named: "bookmarked")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "bookmark")?.withRenderingMode(.alwaysOriginal)
        }
    }
    
    
    private func updateBookmarkButton() {
        bookmarkButton?.image = favouriteNewsDetailViewControllerManager.hasFavouritedCurrentNewsItem() ? UIImage(named: "bookmarked")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "bookmark")?.withRenderingMode(.alwaysOriginal)
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


extension FavouriteNewsDetailViewController: UIScrollViewDelegate {
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate, let collectionView = collectionView {
            favouriteNewsDetailViewControllerManager.updateIndex(of: collectionView)
            updateBookmarkButton()
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let collectionView = collectionView {
            favouriteNewsDetailViewControllerManager.updateIndex(of: collectionView)
            updateBookmarkButton()
        }
    }
    
}


extension FavouriteNewsDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favouriteNewsDetailViewControllerManager.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return favouriteNewsDetailViewControllerManager.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
}
