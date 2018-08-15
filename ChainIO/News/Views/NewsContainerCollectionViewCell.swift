//
//  NewsContainerCollectionViewCell.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/8/14.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class NewsContainerCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    let newsTableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(newsTableView)
        
        newsTableView.delegate = self
        newsTableView.dataSource = self
        newsTableView.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(256)) / 255.0, green: CGFloat(arc4random_uniform(256)) / 255.0, blue: CGFloat(arc4random_uniform(256)) / 255.0, alpha: 1.0)
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
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
