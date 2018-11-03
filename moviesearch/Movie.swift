//
//  Movie.swift
//  moviesearch
//
//  Created by Ilya Kalinin on 02/11/2018.
//  Copyright © 2018 Ilya Kalinin. All rights reserved.
//

import Foundation

struct Movie {
    var title: String?
    var description: String?
    var rating: Float = 0.0
    var release: String?
    var posterPath: String?
    
    // Build poster image URL if possible
    func posterURL() -> URL? {
        guard let basePath = Configuration.getImagePath() else {
            return nil
        }
        
        guard let posterPath = posterPath else {
            return nil
        }
        
        return URL(string: basePath + posterPath)
    }
}
