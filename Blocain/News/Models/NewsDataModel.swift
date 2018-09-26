//
//  NewsDataModel.swift
//  Blocain
//
//  Created by Lihao Li on 2018/9/23.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import Foundation

struct NewsDataModel: Codable {
    let id: Int
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
}


struct Summary: Codable {
    let sentences: [String]?
    
    enum CodingKeys: String, CodingKey {
        case sentences
    }
}


//TODO: rename later


struct NewsSource: Codable {
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case name
    }
}


struct Author: Codable {
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case name
    }
}


struct MediaObject: Codable {
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
}
