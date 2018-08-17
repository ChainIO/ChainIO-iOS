//
//  OrderableSection.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/8/4.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class OrderableSection: FlowLayoutOrderableSectionProtocol {
    
    var registerClassesAndNibs: ((UICollectionView) -> Void)?
    
    var numberOfItems: ((UICollectionView, Int) -> Int)!
    
    var cellForItem: ((UICollectionView, IndexPath) -> UICollectionViewCell)!
    
    var didSelectItem:((UICollectionView, IndexPath) -> Void)?
    
    var viewForSupplementaryElement:((UICollectionView, String, IndexPath) -> Void)?
    
    var sizeForItem: ((UICollectionView, UICollectionViewLayout, IndexPath) -> CGSize)?
    
    var inset: ((UICollectionView, UICollectionViewLayout, Int) -> UIEdgeInsets)?
    
    var minimumLineSpacing: ((UICollectionView, UICollectionViewLayout, Int) -> CGFloat)?
    
    var minimumInteritemSpacing: ((UICollectionView, UICollectionViewLayout, Int) -> CGFloat)?
    
    var referenceSizeForHeader: ((UICollectionView, UICollectionViewLayout, Int) -> CGSize)?
    
    var referenceSizeForFooter: ((UICollectionView, UICollectionViewLayout, Int) -> CGSize)?
    
    func registerClassesAndNibsForCollectionView(_ collectionView: UICollectionView) {
        if let registerClassesAndNibs = registerClassesAndNibs {
            registerClassesAndNibs(collectionView)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems(collectionView, section)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cellForItem(collectionView, indexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let didSelectItem = didSelectItem {
            didSelectItem(collectionView, indexPath)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let viewForSupplementaryElement = viewForSupplementaryElement {
            viewForSupplementaryElement(collectionView, kind, indexPath)
        }
        return UICollectionReusableView()
    }
    
    
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let sizeForItem = sizeForItem {
            return sizeForItem(collectionView, collectionViewLayout, indexPath)
        }else {
            if let collectionViewLayout  = collectionViewLayout as? UICollectionViewFlowLayout {
                return collectionViewLayout.itemSize
            }else {
                return CGSize.zero
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let inset = inset {
            return inset(collectionView, collectionViewLayout, section)
        }else {
            if let collectionViewLayout  = collectionViewLayout as? UICollectionViewFlowLayout {
                return collectionViewLayout.sectionInset
            }else {
                return UIEdgeInsets.zero
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let minimumLineSpacing = minimumLineSpacing {
            return minimumLineSpacing(collectionView, collectionViewLayout, section)
        }else {
            if let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout {
                return collectionViewLayout.minimumLineSpacing
            }else {
                return 0.0
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let minimumInteritemSpacing = minimumInteritemSpacing {
            return minimumInteritemSpacing(collectionView, collectionViewLayout, section)
        }else {
            if let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout {
                return collectionViewLayout.minimumInteritemSpacing
            }else {
                return 0.0
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let referenceSizeForHeader = referenceSizeForHeader {
            return referenceSizeForHeader(collectionView, collectionViewLayout, section)
        }else {
            if let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout {
                return collectionViewLayout.headerReferenceSize
            }else {
                return CGSize.zero
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let referenceSizeForFooter = referenceSizeForFooter {
            return referenceSizeForFooter(collectionView, collectionViewLayout, section)
        }else {
            if let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout {
                return collectionViewLayout.footerReferenceSize
            }else {
                return CGSize.zero
            }
        }
    }
}
