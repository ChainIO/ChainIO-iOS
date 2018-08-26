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
}

class NewsContainerCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: NewsContainerCollectionViewCellDelegate?
    
    let newsTableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
    
    var didRequestMore = false
    
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
