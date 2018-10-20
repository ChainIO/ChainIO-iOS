//
//  NewsDataModel.swift
//  Blocain
//
//  Created by Lihao Li on 2018/9/23.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import Foundation

struct NewsDataModel: Codable, Equatable {
    let id: Int?
    let title: String?
    let body: String?
    let summary: Summary?
    let source: NewsSource?
    let author: Author?
    let wordCount: Int?
    let publishedAt: String?
    let media: [MediaObject]?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case body = "body"
        case summary = "summary"
        case source = "source"
        case author = "author"
        case wordCount = "words_count"
        case publishedAt = "published_at"
        case media = "media"
    }
    
    
    static func == (lhs: NewsDataModel, rhs: NewsDataModel) -> Bool {
        return lhs.id == rhs.id
    }
}


extension NewsDataModel: Hashable {
    var hashValue: Int {
        return id.hashValue
    }
}


class Summary: NSObject, Codable, NSCoding {
    
    let sentences: [String]?
    
    enum CodingKeys: String, CodingKey {
        case sentences
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        self.sentences = aDecoder.decodeObject(forKey: "sentences") as? [String]
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(sentences, forKey: "sentences")
    }
    
}


//TODO: rename later


class NewsSource: NSObject, Codable, NSCoding {
    
    let name: String?
    let id: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as? String
        self.id = aDecoder.decodeObject(forKey: "id") as! Int
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(id, forKey: "id")
    }
    
}


class Author: NSObject, Codable, NSCoding {
    
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as? String
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
    }
    
}


class MediaObject: NSObject, Codable, NSCoding {
   
    let type: String?
    let url: String?
    let width: Int?
    let height: Int?
    
    enum CodingKeys: String, CodingKey {
        case type
        case url
        case width
        case height
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        type = aDecoder.decodeObject(forKey: "type") as? String
        url = aDecoder.decodeObject(forKey: "url") as? String
        width = aDecoder.decodeObject(forKey: "width") as? Int
        height = aDecoder.decodeObject(forKey: "height") as? Int
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(type, forKey: "type")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(width, forKey: "width")
        aCoder.encode(height, forKey: "height")
    }
    
}
