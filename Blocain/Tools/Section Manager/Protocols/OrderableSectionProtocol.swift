//
//  OrderableSectionProtocol.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/8/4.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

@objc protocol OrderableSectionProtocol: AnyObject {
    func registerClassesAndNibsForCollectionView(_ collectionView: UICollectionView)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    
    @objc optional func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
}
