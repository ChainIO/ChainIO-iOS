//
//  EmptyFavouriteTableViewCell.swift
//  Blocain
//
//  Created by Lihao Li on 2018/10/11.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class EmptyFavouriteTableViewCell: UITableViewCell {
    
    private let iconImageView = UIImageView()
    private let textInfoLabel = UILabel()

    class var defaultIdentifier: String {
        return NSStringFromClass(self.classForCoder())
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        iconImageView.image = UIImage(named: "ic-pleasebookmark")
        contentView.addSubview(iconImageView)
        
        textInfoLabel.text = "Nothing here. Try bookmark something!"
        textInfoLabel.font = UIFont.systemFont(ofSize: 14.0)
        textInfoLabel.textColor = .black
        textInfoLabel.textAlignment = .left
        contentView.addSubview(textInfoLabel)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let textInfoLabelSize = textInfoLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 16.0))
        textInfoLabel.frame = CGRect(x: (contentView.bounds.width - textInfoLabelSize.width) / 2.0, y: (contentView.bounds.height - textInfoLabelSize.height) / 2.0, width: textInfoLabelSize.width, height: textInfoLabelSize.height)
        
        let imageWidth = iconImageView.image?.size.width ?? 0.0
        let imageHeight = iconImageView.image?.size.height ?? 0.0
        iconImageView.frame = CGRect(x: (contentView.bounds.width - imageWidth) / 2.0, y: textInfoLabel.frame.minY - 17 - imageHeight, width: imageWidth, height: imageHeight)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
