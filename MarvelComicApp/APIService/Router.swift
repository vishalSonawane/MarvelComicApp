//
//  Router.swift
//  MarvelComicApp
//
//  Created by Vishal Sonawane on 02/05/22.
//

import Foundation
import CryptoKit

let BASE_URL = "https://gateway.marvel.com:443/v1/public/"

enum Router{
    case getCharacters([String:String])
    case getCharacterDetails(String)
    
    var method: String {
      switch self {
      case .getCharacters(_),.getCharacterDetails(_):
          return "GET"
      }
    }
    
    var path: String {
        switch self {
        case .getCharacters(_):
            return "characters"
        case .getCharacterDetails(let characterId):
            return "characters\(characterId)"
        }
    }
    
    func asURLRequest() -> URLRequest? {
        guard let url = URL(string: BASE_URL) else{
            return nil
        }
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method
        switch self {
        case .getCharacters(let params):
            var urlComponents = URLComponents(string: BASE_URL)!
            urlComponents.queryItems = getQueryItems(params: params)
            urlRequest = URLRequest(url: urlComponents.url!.appendingPathComponent(path))
        default:
            break
        }
        
        
        return urlRequest
    }
    
    fileprivate func getQueryItems(params:[String:String]) -> [URLQueryItem] {
        var newParams = params
        let timestamp = Date().timeIntervalSince1970.description
        let md5 = MD5(string: "\(timestamp)\(Keys.API_PRIVATE_KEY)\(Keys.API_PUBLIC_KEY)")
        newParams["hash"] = md5
        newParams["ts"] = timestamp
        var queryItems:[URLQueryItem] = []
        for param in newParams{
            let queryItem = URLQueryItem(name: param.key, value: param.value)
            queryItems.append(queryItem)
        }
        return queryItems
    }
        
    func MD5(string: String) -> String {
        let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }


}
