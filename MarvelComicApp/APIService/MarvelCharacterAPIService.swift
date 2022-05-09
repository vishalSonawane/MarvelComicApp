//
//  MarvelCharacterAPIService.swift
//  MarvelComicApp
//
//  Created by Vishal Sonawane on 03/05/22.
//

import Foundation

protocol APIService{
    func fetchMarvelCharaters(params:[String:String],completion: @escaping(Result<MarvelCharacterResponse?,Error>)->())
}

class MarvelCharacterAPIService: APIService {
    func fetchMarvelCharaters(params: [String : String], completion: @escaping(Result<MarvelCharacterResponse?, Error>) -> ()) {
        APIManager.shared.fetchCharacters(params: params) { response, error in
            if let error = error {
                completion(.failure(error))
            }else{
                completion(.success(response))
            }
        }
    }
}
