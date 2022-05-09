//
//  Utilities.swift
//  MarvelComicApp
//
//  Created by Vishal Sonawane on 08/05/22.
//

import Foundation
import Reachability

class Utilities {
    static func internetConnectionAvailable() -> Bool {
        do{
            return try Reachability(hostname: "www.google.com").connection != .unavailable
        }catch{
            print("Failed to create reachability object")
            return false
        }
    }
}
