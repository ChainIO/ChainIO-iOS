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
    func newsContainerCollectionViewCellDidWantToRefresh(_ newsContainerCollectionViewCell: UICollectionViewCell)
    
    func newsContainerCollectionViewCell(_ newsContainerCollectionViewCell: UICollectionViewCell, didTapCell index: Int)
}

class NewsContainerCollectionViewCell: UICollectionViewCell {
    
    var delegate: NewsContainerCollectionViewCellDelegate?
    
    private let newsTableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
    
    private let refreshControl = UIRefreshControl()
    
    var didRequestMore = false
    
    private var isShowingDetailView = false
    
    private var transitionStartPoint: CGPoint?
    
    private var newsDetailIndex: Int?
    
    var viewModels: [NewsTableViewCellModelProtocol] {
        didSet {
            refreshControl.endRefreshing()
            newsTableView.reloadData()
            didRequestMore = false
        }
    }
    
    
    override init(frame: CGRect) {
        viewModels = [NewsTableViewCellModelProtocol]()
        
        super.init(frame: frame)
        
        newsTableView.refreshControl = refreshControl
        newsTableView.separatorStyle = .none
        newsTableView.register(NewsTableViewCell.classForCoder(), forCellReuseIdentifier: NewsTableViewCell.defaultIdentifier)
        newsTableView.delegate = self
        newsTableView.dataSource = self
        addSubview(newsTableView)
        
        refreshControl.addTarget(self, action: #selector(self.pullToRefresh), for: .valueChanged)
        refreshControl.tintColor = UIColor(red: 0.25, green: 0.72, blue: 0.85, alpha: 1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching News", attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.25, green: 0.72, blue: 0.85, alpha: 1.0)])
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        newsTableView.frame = contentView.frame
    }
    
    
    class func defaultReuseIdentifier() -> String {
        return NSStringFromClass(classForCoder())
    }
    
    
    func tableViewScroll(to index: Int) {
        newsTableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: false)
        let rowsToLoadFromBottom = 10;
        let rowsLoaded = viewModels.count
        if !didRequestMore && index == rowsLoaded - rowsToLoadFromBottom {
            didRequestMore = true
            delegate?.newsContainerCollectionViewCell(self, didWantToLoadNextPage: Int(ceil(Double(viewModels.count) / 20.0)) + 1)
        }
    }
    

    func newsDetailViewTappedBookmarkButton() {
        if let index = newsDetailIndex {
            delegate?.newsContainerCollectionViewCell(self, didWantToFavorite: index)
        }
    }
    
    
    @objc private func pullToRefresh() {
        delegate?.newsContainerCollectionViewCellDidWantToRefresh(self)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension NewsContainerCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
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
        }
        delegate?.newsContainerCollectionViewCell(self, didTapCell: indexPath.row)
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
    
}
