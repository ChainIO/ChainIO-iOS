//
//  NewsDetailContainerCollectionViewCellModel.swift
//  Blocain
//
//  Created by Lihao Li on 2018/9/28.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit
import Nuke


@objc protocol NewsDetailContainerCollectionViewCellModelListenerProtocol: class {
    func didWantToReloadCollectionView()
}


protocol NewsDetailContainerCollectionViewCellModelProtocol {
    
    func addListener(_ listener: NewsDetailContainerCollectionViewCellModelListenerProtocol)
    func removeListener(_ listener: NewsDetailContainerCollectionViewCellModelListenerProtocol)
    
    func registerCells(in collectionView: UICollectionView)
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
}


class NewsDetailContainerCollectionViewCellModel: NewsDetailContainerCollectionViewCellModelProtocol {
    
    private var listeners = NSHashTable<NewsDetailContainerCollectionViewCellModelListenerProtocol>.weakObjects()
    
    private let newsDataModel: NewsDataModel
    
    private enum NewsDetailCollectionViewCellType {
        case source
        case title
        case summary
        case info
        case image
        case body
    }
    private var cellTypesArray = [NewsDetailCollectionViewCellType]()
    private var image: UIImage?
    
    init(newsDataModel: NewsDataModel) {
        self.newsDataModel = newsDataModel
        
        updateCellsType()
    }
    
    
    private func updateCellsType() {
        if let _ = newsDataModel.source?.name {
            cellTypesArray.append(.source)
        }
        if let _ = newsDataModel.title {
            cellTypesArray.append(.title)
        }
        if let _ = newsDataModel.summary {
            cellTypesArray.append(.summary)
        }
        if let _ = newsDataModel.publishedAt {
            cellTypesArray.append(.info)
        }else if let _ = newsDataModel.author?.name {
            cellTypesArray.append(.info)
        }else if let _ = newsDataModel.wordCount {
            cellTypesArray.append(.info)
        }
        
        if let media = newsDataModel.media {
            for i in 0..<media.count {
                let mediaObject = media[i]
                if let url = mediaObject.url {
                    if mediaObject.type == "image" && url.count > 4 && !url.hasSuffix(".gif") {
                        cellTypesArray.append(.image)
                        downloadImage(urlString: url)
                        break
                    }
                }
            }
        }
        
        if let _ = newsDataModel.body {
            cellTypesArray.append(.body)
        }
    }
    
    
    private func downloadImage(urlString: String) {
        if let url = URL(string: urlString) {
            _ = ImagePipeline.shared.loadImage(with: url, progress: nil) {[weak self] (response, _) in
                guard let self = self else { return }
                self.image = response?.image
                
                let enumerator = self.listeners.objectEnumerator()
                while let listener = enumerator.nextObject() as? NewsDetailContainerCollectionViewCellModelListenerProtocol {
                    listener.didWantToReloadCollectionView()
                }
            }
        }
        
    }
    
    
    //NewsDetailContainerCollectionViewCellModelProtocol
    
    
    func addListener(_ listener: NewsDetailContainerCollectionViewCellModelListenerProtocol) {
        listeners.add(listener)
        
        if let _ = self.image {
            let enumerator = self.listeners.objectEnumerator()
            while let listener = enumerator.nextObject() as? NewsDetailContainerCollectionViewCellModelListenerProtocol {
                listener.didWantToReloadCollectionView()
            }
        }
    }
    
    
    func removeListener(_ listener: NewsDetailContainerCollectionViewCellModelListenerProtocol) {
        listeners.remove(listener)
    }
    
    
    func registerCells(in collectionView: UICollectionView) {
        cellTypesArray.forEach { (cellType) in
            switch cellType {
            case .source:
                collectionView.register(NewsDetailSourceCell.classForCoder(), forCellWithReuseIdentifier: NewsDetailSourceCell.defaultIdentifier)
                break
            case .title:
                collectionView.register(NewsDetailTitleCell.classForCoder(), forCellWithReuseIdentifier: NewsDetailTitleCell.defaultIdentifier)
                break
            case .summary:
                collectionView.register(NewsDetailSummaryCell.classForCoder(), forCellWithReuseIdentifier: NewsDetailSummaryCell.defaultIdentifier)
                break
            case .info:
                collectionView.register(NewsDetailInfoCell.classForCoder(), forCellWithReuseIdentifier: NewsDetailInfoCell.defaultIdentifier)
                break
            case .image:
                collectionView.register(NewsDetailImageCell.classForCoder(), forCellWithReuseIdentifier: NewsDetailImageCell.defaultIdentifier)
                break
            case .body:
                collectionView.register(NewsDetailBodyCell.classForCoder(), forCellWithReuseIdentifier: NewsDetailBodyCell.defaultIdentifier)
                break
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellTypesArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cellTypesArray[indexPath.item] {
        case .source:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsDetailSourceCell.defaultIdentifier, for: indexPath) as! NewsDetailSourceCell
            cell.sourceName = newsDataModel.source?.name ?? ""
            return cell
        case .title:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsDetailTitleCell.defaultIdentifier, for: indexPath) as! NewsDetailTitleCell
            cell.title = newsDataModel.title
            return cell
        case .summary:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsDetailSummaryCell.defaultIdentifier, for: indexPath) as! NewsDetailSummaryCell
            cell.loadSummary(summaryArray: newsDataModel.summary?.sentences)
            return cell
        case .info:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsDetailInfoCell.defaultIdentifier, for: indexPath) as! NewsDetailInfoCell
            cell.infoText = NSAttributedString.getInfoText(newsDataModel: newsDataModel)
            return cell
        case .image:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsDetailImageCell.defaultIdentifier, for: indexPath) as! NewsDetailImageCell
            cell.image = image
            return cell
        case .body:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsDetailBodyCell.defaultIdentifier, for: indexPath) as! NewsDetailBodyCell
            cell.body = newsDataModel.body
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch cellTypesArray[indexPath.item] {
        case .source:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsDetailSourceCell.defaultIdentifier, for: indexPath) as! NewsDetailSourceCell
            cell.sourceName = newsDataModel.source?.name ?? ""
            return cell.sizeThatFits(CGSize(width: collectionView.bounds.width, height: CGFloat.leastNonzeroMagnitude))
        case .title:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsDetailTitleCell.defaultIdentifier, for: indexPath) as! NewsDetailTitleCell
            cell.title = newsDataModel.title
            return cell.sizeThatFits(CGSize(width: collectionView.bounds.width, height: CGFloat.leastNonzeroMagnitude))
        case .summary:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsDetailSummaryCell.defaultIdentifier, for: indexPath) as! NewsDetailSummaryCell
            cell.loadSummary(summaryArray: newsDataModel.summary?.sentences)
            return cell.sizeThatFits(CGSize(width: collectionView.bounds.width, height: CGFloat.leastNonzeroMagnitude))
        case .info:
            let infoLabel = UILabel()
            infoLabel.attributedText = NSAttributedString.getInfoText(newsDataModel: newsDataModel)
            infoLabel.numberOfLines = 0
            infoLabel.textAlignment = .left
            infoLabel.font = UIFont.systemFont(ofSize: 14.0)
            let size = infoLabel.sizeThatFits(CGSize(width: collectionView.bounds.width - 60, height: CGFloat.greatestFiniteMagnitude))
            return CGSize(width: collectionView.bounds.width, height: size.height + 32 + 19)
        case .image:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsDetailImageCell.defaultIdentifier, for: indexPath) as! NewsDetailImageCell
            cell.image = image
            return cell.sizeThatFits(CGSize(width: collectionView.bounds.width, height: CGFloat.leastNonzeroMagnitude))
        case .body:
            let bodyLabel = UILabel()
            bodyLabel.font = UIFont(name: "Georgia", size: 16.0)
            bodyLabel.textAlignment = .left
            bodyLabel.numberOfLines = 0
            bodyLabel.text = newsDataModel.body
            bodyLabel.setLineSpacing(lineSpacing: 14.0, lineHeightMultiple: 1.0, headIndent: 0.0)
            let size = bodyLabel.sizeThatFits(CGSize(width: collectionView.bounds.width - 60, height: CGFloat.greatestFiniteMagnitude))
            return CGSize(width: collectionView.bounds.width, height: size.height + 32)
        }
    }
}
