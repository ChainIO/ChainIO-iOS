//
//  NewsContainerCollectionViewCell.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/8/14.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class NewsContainerCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    let newsTableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
    
    var dataSource: [NewsContentEntity]? {
        didSet {
            newsTableView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(newsTableView)
        
        newsTableView.delegate = self
        newsTableView.dataSource = self
        
        newsTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "UITableViewCell")
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
        return dataSource?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = dataSource?[indexPath.row].title
        return cell
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
