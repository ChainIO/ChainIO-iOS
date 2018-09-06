//
//  NewsDetailViewControllerScrollContentProvider.swift
//  Blocain
//
//  Created by Lihao Li on 2018/9/1.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit
import WebKit

@objc protocol NewsDetailViewControllerScrollHelperListenerProtocol {
    @objc optional func newsDetailViewControllerScrollHelper(_ helper: NewsDetailViewControllerScrollHelper, deleteCellAt indexPaths: [IndexPath])
    @objc optional func newsDetailViewControllerScrollHelper(_ helper: NewsDetailViewControllerScrollHelper, insertCellAt indexPaths: [IndexPath])
    
    @objc optional func newsDetailViewControllerScrollHelper(inStream centerIndex: Int)
}

protocol NewsDetailViewControllerScrollHelperProtocol {
    var collectionViewInitialIndex: Int {get}
    var collectionViewPreviousIndex: Int? {get set}
    
    func addListener(_ listener: NewsDetailViewControllerScrollHelperListenerProtocol)
    func removeListener(_ listener: NewsDetailViewControllerScrollHelperListenerProtocol)
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    func collectionView(_ collectionView: UICollectionView, scrollFrom previousIndex: Int,  to currentIndex: Int)
}


class NewsDetailViewControllerScrollHelper: NSObject {
    
    private let contentProvider: NewsViewControllerContentProviderProtocol!
    
    private var indexInStream: Int
    var collectionViewPreviousIndex: Int?
    
    private var contentArray: [NewsContentEntity]? {
        return self.contentProvider.content.contentsDictionary[self.contentProvider.content.titlesArray[self.contentProvider.index]]
    }
    
    private var dataSource: [NewsContentEntity]!
    private var webViewsArray: [WKWebView]!
    
    private var listeners = NSHashTable<NewsDetailViewControllerScrollHelperListenerProtocol>.weakObjects()
    
    var collectionViewInitialIndex: Int {
        if dataSource.count <= 1 {
            return 0
        }else if dataSource.count == 2 {
            if indexInStream == 0 {
                return 0
            }else {
                return 1
            }
        }else {
            return 1
        }
    }
    
    init(contentProvider: NewsViewControllerContentProviderProtocol, indexInStream: Int) {
        self.contentProvider = contentProvider
        self.indexInStream = indexInStream
        self.dataSource = [NewsContentEntity]()
        self.webViewsArray = [WKWebView]()
            
        super.init()
    
        self.getDataSource()
    }
    
    
    func addListener(_ listener: NewsDetailViewControllerScrollHelperListenerProtocol) {
        listeners.add(listener)
    }
    
    
    func removeListener(_ listener: NewsDetailViewControllerScrollHelperListenerProtocol) {
        listeners.remove(listener)
    }
    
    
    private func getDataSource() {
        guard let contentArray = contentArray else {
            return
        }
        
        if contentArray.count < 3 {
            dataSource.append(contentsOf: contentArray)
        }else if indexInStream == 0 {
            for i in 0..<contentArray.count {
                dataSource.append(contentArray[i])
                if i == 1 {
                    break
                }
            }
        }else if indexInStream == contentArray.count - 1 {
            for i in (0...1).reversed() {
                if indexInStream - i >= 0 && indexInStream - i < contentArray.count {
                    dataSource.append(contentArray[indexInStream - i])
                }
            }
        }else {
            for i in stride(from: -1, to: 2, by: 1) {
                if indexInStream + i >= 0 && indexInStream + i < contentArray.count {
                    dataSource.append(contentArray[indexInStream + i])
                }
            }
        }
        
        for newsContentEntity in dataSource {
            if let url = URL(string: newsContentEntity.url) {
                let request = URLRequest(url: url)
                let webView = WKWebView()
                webView.load(request)
                
                webViewsArray.append(webView)
            }
        }
        
    }
}


extension NewsDetailViewControllerScrollHelper: NewsDetailViewControllerScrollHelperProtocol {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsDetailCollectionViewCell.defaultIdentifier, for: indexPath) as! NewsDetailCollectionViewCell
        cell.webView = webViewsArray[indexPath.item]
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, scrollFrom previousIndex: Int,  to currentIndex: Int) {
        
        guard var contentArray = contentArray else {
            return
        }
        
        indexInStream += currentIndex - previousIndex
        
        let enumerator = self.listeners.objectEnumerator()
        while let listener = enumerator.nextObject() as? NewsDetailViewControllerScrollHelperListenerProtocol {
            listener.newsDetailViewControllerScrollHelper?(inStream: indexInStream)
        }
        
        if previousIndex < currentIndex && indexInStream + 1 < contentArray.count {
            if dataSource.count > 2 {
                dataSource.removeFirst()
                webViewsArray.removeFirst()
                
                let enumerator = self.listeners.objectEnumerator()
                while let listener = enumerator.nextObject() as? NewsDetailViewControllerScrollHelperListenerProtocol {
                    listener.newsDetailViewControllerScrollHelper?(self, deleteCellAt: [IndexPath(item: 0, section: 0)])
                }
            }
            dataSource.append(contentArray[indexInStream + 1])
            if let last = dataSource.last, let url = URL(string: last.url) {
                let request = URLRequest(url: url)
                let webView = WKWebView()
                webView.load(request)
                
                webViewsArray.append(webView)
            }
           
            let enumerator = self.listeners.objectEnumerator()
            while let listener = enumerator.nextObject() as? NewsDetailViewControllerScrollHelperListenerProtocol {
                listener.newsDetailViewControllerScrollHelper?(self, insertCellAt: [IndexPath(item: dataSource.count - 1, section: 0)])
            }
        } else if previousIndex > currentIndex && indexInStream - 1 > 0 {
            if dataSource.count > 2 {
                let indexPath = IndexPath(item: dataSource.count - 1, section: 0)
                dataSource.removeLast()
                webViewsArray.removeLast()
                
                let enumerator = self.listeners.objectEnumerator()
                while let listener = enumerator.nextObject() as? NewsDetailViewControllerScrollHelperListenerProtocol {
                    listener.newsDetailViewControllerScrollHelper?(self, deleteCellAt: [indexPath])
                }
            }
            dataSource.insert(contentArray[indexInStream - 1], at: 0)
            if let first = dataSource.first, let url = URL(string: first.url) {
                let request = URLRequest(url: url)
                let webView = WKWebView()
                webView.load(request)
                
                webViewsArray.insert(webView, at: 0)
            }
            
            let enumerator = self.listeners.objectEnumerator()
            while let listener = enumerator.nextObject() as? NewsDetailViewControllerScrollHelperListenerProtocol {
                listener.newsDetailViewControllerScrollHelper?(self, insertCellAt: [IndexPath(item: 0, section: 0)])
            }
        }
    }
    
}
