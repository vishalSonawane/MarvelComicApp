//
//  APIManager.swift
//  MarvelComicApp
//
//  Created by Vishal Sonawane on 02/05/22.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    
    private init(){
        
    }
    
    private var sessionManager: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 180
        return URLSession(configuration: configuration)
    }()
    
    //https://gateway.marvel.com:443/v1/public/characters?limit=5&offset=0&apikey=f2c7910716bc73d22a7c9ad114c5ec9e
    func fetchCharacters(params:[String:String],completionHandler: @escaping ((MarvelCharacterResponse?,Error?)->Void)){
        guard let request = Router.getCharacters(params).asURLRequest() else{
            completionHandler(nil,NSError(domain: "com.marvel.app", code: -1, userInfo: [NSLocalizedDescriptionKey:"Unable to prepare request"]))
            return
        }
        sessionManager.dataTask(with:request) { responseData, response, error in
            if let error = error {
                completionHandler(nil,error)
            }else{
                if let data = responseData{
                    do{
                        let response = try JSONDecoder().decode(MarvelCharacterResponse.self, from: data)
                        completionHandler(response,nil)
                    }catch(let err){
                        completionHandler(nil,err)
                    }
                }else{
                    completionHandler(nil,NSError(domain: "com.marvel.app", code: -1, userInfo: [NSLocalizedDescriptionKey:"Unable to prepare characters array from the response"]))
                }
            }
        }.resume()
    }
}

