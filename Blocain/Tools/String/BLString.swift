//
//  BLString.swift
//  Blocain
//
//  Created by Lihao Li on 2018/10/4.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit

extension NSAttributedString {
    static func getInfoText(newsDataModel: NewsDataModel) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        
        if let wordCount = newsDataModel.wordCount {
            let originalString = "\(max(1, wordCount / 200)) mins read"
            let string: NSString = NSString(string: originalString)
            let tmp = NSMutableAttributedString(string: originalString)
            tmp.addAttributes([NSAttributedStringKey.foregroundColor: UIColor(red: 68 / 255.0, green: 68 / 255.0, blue: 68 / 255.0, alpha: 1.0)], range: string.range(of: originalString))
            attributedString.append(tmp)
        }
        
        if let author = newsDataModel.author?.name {
            let string: NSString = NSString(string: " · " + author)
            let tmp = NSMutableAttributedString(string: " · " + author)
            tmp.addAttributes([NSAttributedStringKey.foregroundColor: UIColor(red: 154 / 255.0, green: 154 / 255.0, blue: 154 / 255.0, alpha: 1.0)], range: string.range(of: string as String))
            attributedString.append(tmp)
        }
        
        if let publishedTime = newsDataModel.publishedAt {
            let timeElapsedString = Date.convertUTCTimeToElapsedTime(utcTime: publishedTime)
            let string: NSString = NSString(string: " · " + timeElapsedString)
            let tmp = NSMutableAttributedString(string: " · " + timeElapsedString)
            tmp.addAttributes([NSAttributedStringKey.foregroundColor: UIColor(red: 154 / 255.0, green: 154 / 255.0, blue: 154 / 255.0, alpha: 1.0)], range: string.range(of: string as String))
            attributedString.append(tmp)
        }
        
        return attributedString
    }
    
    
    static func getFavouriteDataModelInfoText(newsFavouriteDataModel: NewsFavouriteDataModel) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        
        if let wordCount = newsFavouriteDataModel.wordCount {
            let originalString = "\(max(1, wordCount / 200)) mins"
            let string: NSString = NSString(string: originalString)
            let tmp = NSMutableAttributedString(string: originalString)
            tmp.addAttributes([NSAttributedStringKey.foregroundColor: UIColor(red: 68 / 255.0, green: 68 / 255.0, blue: 68 / 255.0, alpha: 1.0)], range: string.range(of: originalString))
            attributedString.append(tmp)
        }
        
        if let author = newsFavouriteDataModel.author?.name {
            let string: NSString = NSString(string: " · " + author)
            let tmp = NSMutableAttributedString(string: " · " + author)
            tmp.addAttributes([NSAttributedStringKey.foregroundColor: UIColor(red: 154 / 255.0, green: 154 / 255.0, blue: 154 / 255.0, alpha: 1.0)], range: string.range(of: string as String))
            attributedString.append(tmp)
        }
        
        if let publishedTime = newsFavouriteDataModel.publishedAt {
            let timeElapsedString = Date.convertUTCTimeToElapsedTime(utcTime: publishedTime)
            let string: NSString = NSString(string: " · " + timeElapsedString)
            let tmp = NSMutableAttributedString(string: " · " + timeElapsedString)
            tmp.addAttributes([NSAttributedStringKey.foregroundColor: UIColor(red: 154 / 255.0, green: 154 / 255.0, blue: 154 / 255.0, alpha: 1.0)], range: string.range(of: string as String))
            attributedString.append(tmp)
        }
        
        return attributedString
    }
}
