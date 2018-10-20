//
//  FavouriteNewsDetailContainerCollectionViewCell.swift
//  Blocain
//
//  Created by Lihao Li on 2018/10/15.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class FavouriteNewsDetailContainerCollectionViewCell: UICollectionViewCell {
    
    class var defaultIdentifier: String {
        return NSStringFromClass(self.classForCoder())
    }
    
    private let collectionView: UICollectionView
    
    var cellModel: FavouriteNewsDetailContainerCollectionViewCellModelProtocol? {
        didSet {
            cellModel?.addListener(self)
            cellModel?.registerCells(in: collectionView)
            collectionView.reloadData()
        }
    }
    
    
    override init(frame: CGRect) {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .vertical
        collectionViewFlowLayout.minimumLineSpacing = 0.0
        collectionViewFlowLayout.estimatedItemSize = CGSize(width: frame.size.width, height: frame.size.height)
        collectionViewFlowLayout.sectionInset = .zero
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.showsVerticalScrollIndicator = true
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        collectionView.backgroundColor = .white
        
        super.init(frame: frame)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        addSubview(collectionView)
    }
    
    
    deinit {
        cellModel?.removeListener(self)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = self.contentView.bounds
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension FavouriteNewsDetailContainerCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let cellModel = cellModel else { return 0 }
        return cellModel.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellModel = cellModel else { return UICollectionViewCell() }
        return cellModel.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cellModel = cellModel else { return CGSize.zero }
        return cellModel.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
    }
    
}


extension FavouriteNewsDetailContainerCollectionViewCell: FavouriteNewsDetailContainerCollectionViewCellModelListenerProtocol {
    func didWantToReloadCollectionView() {
        collectionView.reloadData()
    }
}
