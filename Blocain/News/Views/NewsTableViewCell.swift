//
//  NewsTableViewCell.swift
//  Blocain
//
//  Created by Lihao Li on 2018/8/20.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit
import Nuke

class NewsTableViewCell: UITableViewCell {
    
    let newsInfoContainerView = UIView()
    private let sourceLabel = UILabel()
    private let titleLabel = UILabel()
    private let infoLabel = UILabel()
    private let newsImageView = UIImageView()
    private let separatorLabel = UILabel()
    
    class var defaultIdentifier: String {
        return "NewsTableViewCell"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        contentView.addSubview(newsInfoContainerView)
        
        sourceLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .bold)
        sourceLabel.textColor = UIColor(red: 74/255.0, green: 144/255.0, blue: 226/255.0, alpha: 1.0)
        sourceLabel.textAlignment = .left
        newsInfoContainerView.addSubview(sourceLabel)
        
        titleLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .left
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.numberOfLines = 0
        newsInfoContainerView.addSubview(titleLabel)
        
        infoLabel.font = UIFont.systemFont(ofSize: 15.0)
        infoLabel.textColor = UIColor(red: 176/255.0, green: 176/255.0, blue: 176/255.0, alpha: 1.0)
        infoLabel.textAlignment = .left
        newsInfoContainerView.addSubview(infoLabel)
        
        newsImageView.backgroundColor = .red
        contentView.addSubview(newsImageView)
        
        separatorLabel.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1.0)
        contentView.addSubview(separatorLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        sourceLabel.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: 14)
        sourceLabel.sizeToFit()
        
        newsImageView.frame = CGRect(x: contentView.frame.width - 15 - 110, y: (contentView.frame.height - 80) / 2.0, width: 110, height: 80)
        
        titleLabel.frame = CGRect(x: 0, y: sourceLabel.frame.maxY + 8, width: newsImageView.isHidden ? contentView.frame.width - 40 : contentView.frame.width - 20 - 9 - 110 - 16, height: 300)
        titleLabel.sizeToFit()
        
        infoLabel.frame = CGRect(x: 0, y: titleLabel.frame.maxY + 9, width: contentView.frame.width, height: 18)
        infoLabel.sizeToFit()
        
        newsInfoContainerView.frame = CGRect(x: 20, y: 20, width: newsImageView.isHidden ? contentView.frame.width - 40 : contentView.frame.width - 20 - 9 - 110 - 16, height: infoLabel.frame.maxY)
        
        separatorLabel.frame = CGRect(x: 0, y: contentView.frame.height - 1, width: contentView.frame.width, height: 1)
    }
    
    
    func loadViewModel(_ viewModel: NewsTableViewCellModelProtocol) {
        newsImageView.isHidden = viewModel.shouldHideImage
        titleLabel.numberOfLines = newsImageView.isHidden ? 3 : 5
        sourceLabel.text = viewModel.sourceName
        titleLabel.text = viewModel.title
        
        if let publishedTime = viewModel.publishedAt {
            infoLabel.text = Date.convertUTCTimeToElapsedTime(utcTime: publishedTime)
        }
        
        if let imageURLString = viewModel.imageURL {
            if let imageURL = URL(string: imageURLString) {
                let options = ImageLoadingOptions(placeholder: nil, transition: .fadeIn(duration: 0.33), failureImage: nil, failureImageTransition: nil, contentModes: nil)
                Nuke.loadImage(with: imageURL, options: options, into: newsImageView, progress: nil, completion: nil)
            }
        }
    }

}
