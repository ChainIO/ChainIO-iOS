//
//  NewsContainerCollectionViewCell.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/8/14.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

protocol NewsContainerCollectionViewCellDelegate: class {
    func newsContainerCollectionViewCell(_ newsContainerCollectionViewCell: UICollectionViewCell, didWantToLoadNextPage page: Int)
    func newsContainerCollectionViewCellDidWantToRefresh(_ newsContainerCollectionViewCell: UICollectionViewCell)
    
    func newsContainerCollectionViewCell(_ newsContainerCollectionViewCell: UICollectionViewCell, didTapCell index: Int)
}

class NewsContainerCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: NewsContainerCollectionViewCellDelegate?
    
    let newsTableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
    
    private let refreshControl = UIRefreshControl()
    
    var didRequestMore = false
    
    private var isShowingDetailView = false
    
    private var transitionStartPoint: CGPoint?
    
    private var newsDetailIndex: Int?
    
    private var errorMessageLabel = UILabel()
    
    var viewModels: [NewsTableViewCellViewModelProtocol] {
        didSet {
            refreshControl.endRefreshing()
            newsTableView.reloadData()
            didRequestMore = false
        }
    }
    
    var errorMessage:String = "" {
        didSet {
            errorMessageLabel.text = errorMessage
            layoutSubviews()
        }
    }
    
    
    override init(frame: CGRect) {
        viewModels = [NewsTableViewCellViewModelProtocol]()
        
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
        
        errorMessageLabel.textAlignment = .center
        errorMessageLabel.backgroundColor = .red
        errorMessageLabel.textColor = .white
        errorMessageLabel.font = UIFont.systemFont(ofSize: 14.0)
        addSubview(errorMessageLabel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModels = [NewsTableViewCellViewModelProtocol]()
        newsTableView.reloadData()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let errorMessageLabelSize = errorMessageLabel.sizeThatFits(CGSize(width: contentView.frame.width, height: contentView.frame.height))
        errorMessageLabel.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: errorMessageLabelSize.height)
        
        newsTableView.frame = CGRect(x: 0, y: errorMessageLabel.frame.maxY, width: contentView.frame.width, height: contentView.frame.height - errorMessageLabel.frame.maxY)
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
        let rowsToLoadFromBottom = 30;
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
        titleLabel.numberOfLines = !viewModel.shouldShowImage ? 3 : 5
        titleLabel.frame.size = CGSize(width: !viewModel.shouldShowImage ? contentView.frame.width - 40 : contentView.frame.width - 20 - 9 - 110 - 16, height: 300)
        titleLabel.text = viewModel.title
        titleLabel.sizeToFit()
        
        return titleLabel.frame.height + 8 + 14 + 20 + 8 + 18 + 20
    }
    
}
