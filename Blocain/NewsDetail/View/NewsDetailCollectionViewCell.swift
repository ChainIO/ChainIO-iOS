//
//  NewsDetailCollectionViewCell.swift
//  Blocain
//
//  Created by Lihao Li on 2018/9/27.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

class NewsDetailCollectionViewCell: UICollectionViewCell {
    
    class var defaultIdentifier: String {
        return NSStringFromClass(self.classForCoder())
    }
    
}


class NewsDetailSourceCell: UICollectionViewCell {
    
    class var defaultIdentifier: String {
        return NSStringFromClass(self.classForCoder())
    }
    
    var sourceName: String? {
        didSet {
            sourceNameLabel.text = sourceName
            sourceNameLabel.setNeedsDisplay()
        }
    }
    
    private let sourceNameLabel = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sourceNameLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        sourceNameLabel.textColor = UIColor(red: 74 / 255.0, green: 144 / 255.0, blue: 226 / 255.0, alpha: 1.0)
        sourceNameLabel.numberOfLines = 0
        sourceNameLabel.textAlignment = .left
        contentView.addSubview(sourceNameLabel)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = sourceNameLabel.sizeThatFits(CGSize(width: contentView.bounds.width - 30 * 2, height: CGFloat.greatestFiniteMagnitude))
        sourceNameLabel.frame = CGRect(x: 30, y: 30, width: size.width, height: size.height)   
    }
    
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let sourceNameLabelSize = sourceNameLabel.sizeThatFits(CGSize(width: size.width - 30 * 2, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: size.width, height: sourceNameLabelSize.height + 30.0)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class NewsDetailTitleCell: UICollectionViewCell {
    
    class var defaultIdentifier: String {
        return NSStringFromClass(self.classForCoder())
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
            titleLabel.setNeedsDisplay()
        }
    }
    
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        contentView.addSubview(titleLabel)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let titleLabelSize = titleLabel.sizeThatFits(CGSize(width: contentView.bounds.width - 30 * 2, height: CGFloat.greatestFiniteMagnitude))
        titleLabel.frame = CGRect(x: 30, y: 10, width: titleLabelSize.width, height: titleLabelSize.height)
    }
    
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let titleLabelSize = titleLabel.sizeThatFits(CGSize(width: size.width - 30 * 2, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: size.width, height: titleLabelSize.height + 10)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class NewsDetailSummaryCell: UICollectionViewCell {
    
    class var defaultIdentifier: String {
        return NSStringFromClass(self.classForCoder())
    }
    
    var summaryText: String? {
        didSet {
            summaryLabel.text = summaryText
            summaryLabel.setLineSpacing(lineSpacing: 14.0, lineHeightMultiple: 1.0, headIndent: NSString(string: "• ").size(withAttributes: [NSAttributedStringKey.font: summaryLabel.font]).width)
            summaryLabel.setNeedsDisplay()
        }
    }
    
    private let summaryLabel = UILabel()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        summaryLabel.font = UIFont.systemFont(ofSize: 16.0)
        summaryLabel.textColor = UIColor(red: 103.0 / 255.0, green: 103.0 / 255.0, blue: 105.0 / 255.0, alpha: 1.0)
        summaryLabel.textAlignment = .left
        summaryLabel.numberOfLines = 0
        contentView.addSubview(summaryLabel)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let summaryLabelSize = summaryLabel.sizeThatFits(CGSize(width: contentView.bounds.width - 30 * 2, height: CGFloat.greatestFiniteMagnitude))
        summaryLabel.frame = CGRect(x: 30.0, y: 16.0, width: summaryLabelSize.width, height: summaryLabelSize.height)
    }
    
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let summaryLabelSize = summaryLabel.sizeThatFits(CGSize(width: size.width - 30 * 2, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: size.width, height: summaryLabelSize.height + 16.0)
    }
    
    
    func loadSummary(summaryArray: [String]?) {
        guard let summaryArray = summaryArray, summaryArray.count > 0 else { return }
        var summaryString = String()
        for summary in summaryArray {
            summaryString.append("• ")
            summaryString.append(summary.trimmingCharacters(in: .whitespacesAndNewlines))
            summaryString.append("\n")
        }
        let finalSummaryString = summaryString.trimmingCharacters(in: .whitespacesAndNewlines)
        summaryText = finalSummaryString
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class NewsDetailInfoCell: UICollectionViewCell {
    
    class var defaultIdentifier: String {
        return NSStringFromClass(self.classForCoder())
    }
    
    var infoText: NSAttributedString? {
        didSet {
            infoLabel.attributedText = infoText
            infoLabel.setNeedsDisplay()
        }
    }
    
    private let infoLabel = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .left
        infoLabel.font = UIFont.systemFont(ofSize: 14.0)
        contentView.addSubview(infoLabel)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let infoLabelSize = infoLabel.sizeThatFits(CGSize(width: contentView.bounds.width - 30 * 2, height: CGFloat.greatestFiniteMagnitude))
        infoLabel.frame = CGRect(x: 30.0, y: 19.0, width: infoLabelSize.width, height: infoLabelSize.height)
    }
    
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let infoLabelSize = infoLabel.sizeThatFits(CGSize(width: size.width - 30 * 2, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: size.width, height: infoLabelSize.height + 19.0 + 32.0)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class NewsDetailImageCell: UICollectionViewCell {
    
    class var defaultIdentifier: String {
        return NSStringFromClass(self.classForCoder())
    }
    
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    private let imageView = UIImageView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let image = image else { return }
        imageView.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.width * image.size.height / image.size.width)
    }
    
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let image = image else { return .zero }
        return CGSize(width: size.width, height: size.width * image.size.height / image.size.width)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class NewsDetailBodyCell: UICollectionViewCell {
    
    class var defaultIdentifier: String {
        return NSStringFromClass(self.classForCoder())
    }
    
    var body: String? {
        didSet {
            bodyTextView.text = body
            bodyTextView.setLineSpacing(lineSpacing: 14.0, lineHeightMultiple: 1.0, headIndent: 0.0)
        }
    }
    
    private let bodyTextView = UITextView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bodyTextView.font = UIFont(name: "Georgia", size: 16.0)
        bodyTextView.textAlignment = .left
        bodyTextView.textColor = UIColor(red: 48 / 255.0, green: 48 / 255.0, blue: 48 / 255.0, alpha: 1.0)
        contentView.addSubview(bodyTextView)
    }
    
    
    override func prepareForReuse() {
        bodyTextView.text = ""
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bodyLabelSize = bodyTextView.sizeThatFits(CGSize(width: contentView.bounds.width - 30 * 2, height: CGFloat.greatestFiniteMagnitude))
        bodyTextView.frame = CGRect(x: 30, y: 32, width: bodyLabelSize.width, height: bodyLabelSize.height)
    }
    
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let bodyLabelSize = bodyTextView.sizeThatFits(CGSize(width: size.width - 30 * 2, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: size.width, height: bodyLabelSize.height + 32 * 2)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
