//
//  NewsDetailViewController.swift
//  Blocain
//
//  Created by Lihao Li on 2018/8/31.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class NewsDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private var scrollHelper: NewsDetailViewControllerScrollHelperProtocol!
    
    private var collectionView: UICollectionView!
    
    private var collectionViewCurrentIndex = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    init(scrollHelper: NewsDetailViewControllerScrollHelperProtocol) {
        super.init(nibName: nil, bundle: nil)
        
        self.scrollHelper = scrollHelper
        scrollHelper.addListener(self)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    deinit {
        scrollHelper.removeListener(self)
    }
    
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        self.navigationController?.navigationBar.barTintColor = .black
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.tappedBackButton))
        backButtonItem.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButtonItem
        let bookmarkButton = UIBarButtonItem(image: UIImage(named: "bookmark"), style: .plain, target: self, action: #selector(self.tappedBookmarkButton))
        bookmarkButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = bookmarkButton
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self;
        
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionViewFlowLayout.minimumLineSpacing = 0
        collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewFlowLayout)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(NewsDetailCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: NewsDetailCollectionViewCell.defaultIdentifier)
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.contentOffset = CGPoint(x: CGFloat(scrollHelper.collectionViewInitialIndex) * view.bounds.width, y: 0)
        collectionViewCurrentIndex = scrollHelper.collectionViewInitialIndex
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
        
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.classForCoder())
    }
    
    
}


extension NewsDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scrollHelper.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return scrollHelper.collectionView(collectionView, cellForItemAt:indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}


extension NewsDetailViewController: NewsDetailViewControllerScrollHelperListenerProtocol {
    
    func newsDetailViewControllerScrollHelper(_ helper: NewsDetailViewControllerScrollHelper, deleteCellAt indexPaths: [IndexPath]) {
        collectionView.deleteItems(at: indexPaths)
        for indexPath in indexPaths {
            if indexPath.item < collectionViewCurrentIndex {
                collectionViewCurrentIndex -= 1
            }
        }
    }
    
    
    func newsDetailViewControllerScrollHelper(_ helper: NewsDetailViewControllerScrollHelper, insertCellAt indexPaths: [IndexPath]) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: indexPaths)
        }) { (finished) in
            if finished {
                for indexPath in indexPaths {
                    if indexPath.item <= self.collectionViewCurrentIndex {
                        self.collectionViewCurrentIndex += 1
                    }
                }
                self.collectionView.contentOffset = CGPoint(x: CGFloat(self.scrollHelper.collectionViewInitialIndex) * self.view.bounds.width, y: 0)
            }
        }
        
        CATransaction.commit()
    }
    
}


extension NewsDetailViewController: UIScrollViewDelegate {
    
    private func updateIndex(notifyScrollHelper: Bool) {
        let index = collectionViewCurrentIndex
        collectionViewCurrentIndex = Int(collectionView.contentOffset.x / collectionView.frame.width)
        if notifyScrollHelper {
            scrollHelper.collectionView(collectionView, scrollFrom: index, to: collectionViewCurrentIndex)
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateIndex(notifyScrollHelper: true)
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateIndex(notifyScrollHelper: true)
        }
    }
}

