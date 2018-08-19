//
//  NewsContentEntity.swift
//  Blocain
//
//  Created by Lihao Li on 2018/8/16.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import Foundation

struct NewsContentEntity: Codable {
    let source: Source?
    let author: String?
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case source
        case author
        case title
        case description
        case url
        case urlToImage
        case publishedAt
    }
}

struct Source: Codable {
    let sourceId: String?
    let sourceName: String?
    
    enum CodingKeys: String, CodingKey {
        case sourceId = "id"
        case sourceName = "name"
    }
}

