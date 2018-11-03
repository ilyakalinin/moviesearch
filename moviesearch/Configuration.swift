//
//  Configuration.swift
//  moviesearch
//
//  Created by Ilya Kalinin on 02/11/2018.
//  Copyright © 2018 Ilya Kalinin. All rights reserved.
//

import Foundation

class Configuration {
    
    private static let apiKey = "a4ad69baec34c0ee99ed5d57add1bbfd"
    private static let defaultURL = "https://api.themoviedb.org/3/"
    
    private static let imagePathKey = "imagePath"
    
    class func getApiKey() -> String {
        return apiKey
    }
    
    class func getServerURL() -> String {
        return defaultURL
    }
    
    class func getImagePath() -> String? {
        let defaults = UserDefaults.standard
        guard let account = defaults.object(forKey: imagePathKey) as? String else {
            return nil
        }
        return account
    }
    
    class func save(imagePath: String?) {
        let defaults = UserDefaults.standard
        defaults.set(imagePath, forKey: imagePathKey)
    }
    
}
