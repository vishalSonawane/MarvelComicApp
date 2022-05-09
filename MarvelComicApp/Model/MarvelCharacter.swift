//
//  MarvelCharacter.swift
//  MarvelComicApp
//
//  Created by Vishal Sonawane on 02/05/22.
//

import Foundation
import RealmSwift

class MarvelCharacterResponse:Codable {
    var code: Int?
    var status:String?
    var etag: String?
    var data: DataClass?
}

// MARK: - DataClass
class DataClass:Codable {
    var offset, limit, total, count: Int?
    var results: [MarvelCharacter]?

    init(offset: Int?, limit: Int?, total: Int?, count: Int?, results: [MarvelCharacter]?) {
        self.offset = offset
        self.limit = limit
        self.total = total
        self.count = count
        self.results = results
    }
}

// MARK: - Result
class MarvelCharacter:Object,Codable {
    @Persisted var id: Int?
    @Persisted var name:String?
    @Persisted var resultDescription: String?
    @Persisted var thumbnail: Thumbnail?
    @Persisted var comics:Comics?
    @Persisted var series: Comics?
    @Persisted var isBookmarked: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id,name,resultDescription,thumbnail,comics,series
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

// MARK: - Comics
class Comics:Object,Codable {
    @Persisted var available: Int?
    @Persisted var collectionURI: String?
    @Persisted var items: List<ComicsItem> = List()
    @Persisted var returned: Int?
}

// MARK: - ComicsItem
class ComicsItem:Object,Codable {
    @Persisted var resourceURI: String?
    @Persisted var name: String?
}

// MARK: - Thumbnail
class Thumbnail:Object,Codable {
    @Persisted var path: String?
    @Persisted var thumbnailExtension: String?
    
    enum CodingKeys: String, CodingKey {
        case thumbnailExtension = "extension"
        case path = "path"
    }
    var thumbanilURLString:String{
        return "\(path ?? "").\(thumbnailExtension ?? "")"
    }
}
