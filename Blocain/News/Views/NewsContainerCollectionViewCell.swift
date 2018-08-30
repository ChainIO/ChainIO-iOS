//
//  NewsContainerCollectionViewCell.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/8/14.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

protocol NewsContainerCollectionViewCellDelegate {
    func newsContainerCollectionViewCell(_ newsContainerCollectionViewCell: UICollectionViewCell, didWantToLoadNextPage page: Int)
    func newsContainerCollectionViewCell(_ newsContainerCollectionViewCell: UICollectionViewCell, didWantToFavorite index: Int)
}

class NewsContainerCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource, NewsDetailViewDelegate {
    
    var delegate: NewsContainerCollectionViewCellDelegate?
    
    let newsTableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
    
    var didRequestMore = false
    private var isShowingDetailView = false
    
    private lazy var newsDetailView: NewsDetailView = {
        let newsDetailView = NewsDetailView()
        newsDetailView.translatesAutoresizingMaskIntoConstraints = false
        return newsDetailView
    }()
    
    private var transitionStartPoint: CGPoint?
    
    private var newsDetailIndex: Int?
    
    var viewModels: [NewsTableViewCellModelProtocol] {
        didSet {
            newsTableView.reloadData()
            didRequestMore = false
        }
    }
    
    
    override init(frame: CGRect) {
        viewModels = [NewsTableViewCellModelProtocol]()
        
        super.init(frame: frame)
        
        newsTableView.separatorStyle = .none
        newsTableView.register(NewsTableViewCell.classForCoder(), forCellReuseIdentifier: NewsTableViewCell.defaultIdentifier)
        newsTableView.delegate = self
        newsTableView.dataSource = self
        addSubview(newsTableView)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        newsTableView.frame = contentView.frame
    }
    
    
    class func defaultReuseIdentifier() -> String {
        return NSStringFromClass(classForCoder())
    }
    
    private func animateNewsDetailView(on row: Int) {
        if !isShowingDetailView {
            isShowingDetailView = true
            newsDetailIndex = row
            newsDetailView.contentURL = viewModels[row].contentURL
            newsDetailView.title = viewModels[row].sourceName
            newsDetailView.delegate = self
            
            UIApplication.shared.keyWindow!.addSubview(newsDetailView)
            UIApplication.shared.keyWindow!.bringSubview(toFront: newsDetailView)
            newsDetailView.center = CGPoint(x: UIScreen.main.bounds.width / 2.0, y: UIScreen.main.bounds.height / 2.0)
            newsDetailView.frame.size = CGSize(width: 20, height: 20)
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
                self.newsDetailView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                self.newsDetailView.alpha = 1.0
            }, completion: nil)
        }else {
            isShowingDetailView = false
            UIView.animate(withDuration: 0.5, delay: 0.2, options: .layoutSubviews, animations: {
                self.newsDetailView.frame = CGRect(x: UIScreen.main.bounds.width / 2.0, y: UIScreen.main.bounds.height / 2.0, width: 0, height: 0)
                self.newsDetailView.alpha = 0.0
            }, completion: { (finished) in
                self.newsDetailView.removeFromSuperview()
            })
        }
    }
    
    
    func newsDetailViewDidWantToDismiss() {
        animateNewsDetailView(on: -1)
    }
    
    
    
    func newsDetailViewTappedBookmarkButton() {
        if let index = newsDetailIndex {
            delegate?.newsContainerCollectionViewCell(self, didWantToFavorite: index)
        }
    }
    
    
    
    // MARK: UITableView
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.defaultIdentifier, for: indexPath) as! NewsTableViewCell
        cell.loadViewModel(viewModels[indexPath.row])
        let rowsToLoadFromBottom = 10;
        let rowsLoaded = viewModels.count
        if !didRequestMore && indexPath.row == rowsLoaded - rowsToLoadFromBottom {
            didRequestMore = true
            delegate?.newsContainerCollectionViewCell(self, didWantToLoadNextPage: Int(ceil(Double(viewModels.count) / 20.0)) + 1)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cellCenter = tableView.cellForRow(at: indexPath)?.center {
            transitionStartPoint = tableView.convert(cellCenter, to: contentView)
            animateNewsDetailView(on: indexPath.row)
        }
       
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let viewModel = viewModels[indexPath.row]
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.numberOfLines = viewModel.shouldHideImage ? 3 : 5
        titleLabel.frame.size = CGSize(width: viewModel.shouldHideImage ? contentView.frame.width - 40 : contentView.frame.width - 20 - 9 - 110 - 16, height: 300)
        titleLabel.text = viewModel.title
        titleLabel.sizeToFit()
        
        return titleLabel.frame.height + 8 + 14 + 20 + 8 + 18 + 20
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
