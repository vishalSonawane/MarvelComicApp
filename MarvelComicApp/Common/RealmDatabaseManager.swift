//
//  RealmDatabaseManager.swift
//  MarvelComicApp
//
//  Created by Vishal Sonawane on 05/05/22.
//

import Foundation
import RealmSwift

enum DatabaseError:Error {
    case failedToSaveObjects
}
extension DatabaseError:CustomStringConvertible{
    public var description: String {
        switch self {
        case .failedToSaveObjects:
            return "Failed to save objects in Realm database."
        }
    }
}

class RealmDatabaseManager {
    static let shared = RealmDatabaseManager()
    let realm = try! Realm()
    
    func saveObjects(objects:[MarvelCharacter]) throws{
        do {
            try realm.write {
                for object in objects{
                    //Do not update isBookmarked flag
                    if let currentObject = realm.object(ofType: MarvelCharacter.self, forPrimaryKey: object.id) {
                        object.isBookmarked = currentObject.isBookmarked
                    }
                }
                realm.add(objects,update: .modified)
            }
        } catch {
            throw DatabaseError.failedToSaveObjects
        }
    }
    
    func fetchAllMarvelCharacters() -> Results<MarvelCharacter> {
        let result = realm.objects(MarvelCharacter.self)
        return result
    }
    func setupRealmConfiguration(){
        //Realm Config
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in})
        Realm.Configuration.defaultConfiguration = config
    }
    func writeCallback(callback:()->()){
        do{
            try realm.write {
                callback()
            }
        }catch{
            print("Write callback error: \(error.localizedDescription)")
        }
    }
}
