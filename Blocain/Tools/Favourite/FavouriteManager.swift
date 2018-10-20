//
//  FavouriteManager.swift
//  Blocain
//
//  Created by Lihao Li on 2018/10/6.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import Foundation

import Mixpanel

class NewsFavouriteDataModel: NSObject, NSCoding {
    
    let id: Int?
    let title: String?
    let body: String?
    let summary: Summary?
    let source: NewsSource?
    let author: Author?
    let wordCount: Int?
    let publishedAt: String?
    let media: [MediaObject]?
    let date: Date?
    
    init(newsDataModel: NewsDataModel) {
        id = newsDataModel.id
        title = newsDataModel.title
        body = newsDataModel.body
        summary = newsDataModel.summary
        source = newsDataModel.source
        author = newsDataModel.author
        wordCount = newsDataModel.wordCount
        publishedAt = newsDataModel.publishedAt
        media = newsDataModel.media
        date = Date()
        
        super.init()
    }
    
    
    init(id: Int?, title: String?, body: String?, summary: Summary?, source: NewsSource?, author: Author?, wordCount: Int?, publishedAt: String?, media: [MediaObject]?, date: Date?) {
        self.id = id
        self.title = title
        self.body = body
        self.summary = summary
        self.source = source
        self.author = author
        self.wordCount = wordCount
        self.publishedAt = publishedAt
        self.media = media
        self.date = date
        
        super.init()
    }
    
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "id") as! Int
        let title = aDecoder.decodeObject(forKey: "title") as! String
        let body = aDecoder.decodeObject(forKey: "body") as! String
        let summary = aDecoder.decodeObject(forKey: "summary") as! Summary
        let source = aDecoder.decodeObject(forKey: "source") as! NewsSource
        let author = aDecoder.decodeObject(forKey: "author") as! Author
        let wordCount = aDecoder.decodeObject(forKey: "wordCount") as! Int
        let publishedAt = aDecoder.decodeObject(forKey: "publishedAt") as! String
        let media = aDecoder.decodeObject(forKey: "media") as! [MediaObject]
        let date = aDecoder.decodeObject(forKey: "date") as! Date
        self.init(id: id, title: title, body: body, summary: summary, source: source, author: author, wordCount: wordCount, publishedAt: publishedAt, media: media, date: date)
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(body, forKey: "body")
        aCoder.encode(summary, forKey: "summary")
        aCoder.encode(source, forKey: "source")
        aCoder.encode(author, forKey: "author")
        aCoder.encode(wordCount, forKey: "wordCount")
        aCoder.encode(publishedAt, forKey: "publishedAt")
        aCoder.encode(media, forKey: "media")
        aCoder.encode(date, forKey: "date")
    }
    
}


extension NewsFavouriteDataModel {
    override var hash: Int {
        return id?.hashValue ?? -1
    }
}


extension NewsFavouriteDataModel {
    static func ==(lhs: NewsFavouriteDataModel, rhs: NewsFavouriteDataModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}


@objc protocol FavouriteManagerListenerProtocol {
    func didChange(favouriteNewsItemWith id: Int, isFavourited: Bool)
}


class FavouriteManager {
    static let sharedManager = FavouriteManager()
    
    private(set) var favouriteNewsDataModelsSet = Set<NewsFavouriteDataModel>()
    
    private var listeners = NSHashTable<FavouriteManagerListenerProtocol>.weakObjects()
    
    private init() {
    }
    
    
    func addListener(_ listener: FavouriteManagerListenerProtocol) {
        listeners.add(listener)
    }
    
    
    func removeListener(_ listener: FavouriteManagerListenerProtocol) {
        listeners.remove(listener)
    }
    
    
    func hasFavouritedNewsItem(_ newsDataModel: NewsDataModel) -> Bool {
        return favouriteNewsDataModelsSet.first{$0.id == newsDataModel.id} != nil
    }
    
    
    func hasFavouritedNewsItem(_ id: Int?) -> Bool {
        guard let id = id else { return false }
        
        return favouriteNewsDataModelsSet.first{$0.id == id} != nil
    }
    
    
    func didWantToUnFavouriteNewsItem(with id: Int) {
        if hasFavouritedNewsItem(id) {
            if let favouriteNewsItem = favouriteNewsDataModelsSet.first(where: {$0.id == id}) {
                favouriteNewsDataModelsSet.remove(favouriteNewsItem)
            }
            let enumerator = listeners.objectEnumerator()
            while let nextObject = enumerator.nextObject() as? FavouriteManagerListenerProtocol {
                nextObject.didChange(favouriteNewsItemWith: id, isFavourited: false)
            }
        }
        trackFavoriteEvent()
    }
    
    
    func didTapFavouriteButton(_ newsDataModel: NewsDataModel, completion: @escaping(Bool) -> Void) {
        if hasFavouritedNewsItem(newsDataModel) {
            if let favouriteNewsItem = favouriteNewsDataModelsSet.first(where: {$0.id == newsDataModel.id}) {
                favouriteNewsDataModelsSet.remove(favouriteNewsItem)
            }
            let enumerator = listeners.objectEnumerator()
            while let nextObject = enumerator.nextObject() as? FavouriteManagerListenerProtocol {
                nextObject.didChange(favouriteNewsItemWith: newsDataModel.id ?? 0, isFavourited: false)
            }
            completion(false)
        }else {
            favouriteNewsDataModelsSet.insert(NewsFavouriteDataModel(newsDataModel: newsDataModel))
            let enumerator = listeners.objectEnumerator()
            while let nextObject = enumerator.nextObject() as? FavouriteManagerListenerProtocol {
                nextObject.didChange(favouriteNewsItemWith: newsDataModel.id ?? 0, isFavourited: true)
            }
            completion(true)
        }
        trackFavoriteEvent()
    }
    
    
    func didTapFavouriteButtonInFavouriteDetailPage(_ newsFavouriteDataModel: NewsFavouriteDataModel, completion: @escaping(Bool) -> Void) {
        if hasFavouritedNewsItem(newsFavouriteDataModel.id) {
            if let favouriteNewsItem = favouriteNewsDataModelsSet.first(where: {$0.id == newsFavouriteDataModel.id}) {
                favouriteNewsDataModelsSet.remove(favouriteNewsItem)
            }
            let enumerator = listeners.objectEnumerator()
            while let nextObject = enumerator.nextObject() as? FavouriteManagerListenerProtocol {
                nextObject.didChange(favouriteNewsItemWith: newsFavouriteDataModel.id ?? 0, isFavourited: false)
            }
            completion(false)
        }else {
            favouriteNewsDataModelsSet.insert(newsFavouriteDataModel)
            let enumerator = listeners.objectEnumerator()
            while let nextObject = enumerator.nextObject() as? FavouriteManagerListenerProtocol {
                nextObject.didChange(favouriteNewsItemWith: newsFavouriteDataModel.id ?? 0, isFavourited: true)
            }
            completion(true)
        }
        trackFavoriteEvent()
    }
    
    
    func saveFavouriteNewsItemsToUserDefaults() {
        let userDefaults = UserDefaults.standard
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: favouriteNewsDataModelsSet)
        userDefaults.set(encodedData, forKey: "favouriteNewsDataModelsSet")
        userDefaults.synchronize()
    }
    
    
    func getFavouriteNewsItemsFromUserDefaults() {
        let userDefaults = UserDefaults.standard
        if let decoded = userDefaults.object(forKey: "favouriteNewsDataModelsSet") as? Data {
            self.favouriteNewsDataModelsSet = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! Set<NewsFavouriteDataModel>
        }
    }
    
    
    private func trackFavoriteEvent() {
        AnalyticManager.sharedManager.setPeopleProperties(property: "Number of news bookmarked", value: favouriteNewsDataModelsSet.count)
        
        var sourceSet = Set<String>()
        favouriteNewsDataModelsSet.forEach { (model) in
            if let sourceName = model.source?.name {
                sourceSet.insert(sourceName)
            }
        }
        var uniqueSourceArray = [String]()
        sourceSet.forEach { (sourceName) in
            uniqueSourceArray.append(sourceName)
        }
        AnalyticManager.sharedManager.setPeopleProperties(property: "Bookmarked News Source List", value: uniqueSourceArray)
    }
    
}
