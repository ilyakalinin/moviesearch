//
//  SearchService.swift
//  moviesearch
//
//  Created by Ilya Kalinin on 02/11/2018.
//  Copyright © 2018 Ilya Kalinin. All rights reserved.
//

import Foundation
import Alamofire

class SearchService {
    
    class func search(query: String, page: Int = 1, completionHandler: @escaping ([Movie]?, Int, Error?) -> Void) {
        ConfigurationService.updateConfigurationIfNeed { (error) in
            let url = Configuration.getServerURL() + "search/movie"
            let parameters: [String: Any] = ["api_key": Configuration.getApiKey(), "query": query, "page": page, "include_adult": false]
            
            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let resultValue):
                        guard let data = resultValue as? [String: AnyObject],
                            let results = data["results"] as? [[String: AnyObject]],
                            let total = data["total_pages"] as? Int
                            else {
                                DispatchQueue.main.async {
                                    completionHandler(nil, 0, nil)
                                }
                                return
                        }
                        
                        // Move to factory method
                        
                        var movies = [Movie]()
                        for result in results {
                            var movie = Movie()
                            if let title = result["title"] as? String {
                                movie.title = title
                            }
                            if let description = result["overview"] as? String {
                                movie.description = description
                            }
                            if let rating = result["vote_average"] as? Float {
                                movie.rating = rating
                            }
                            if let release = result["release_date"] as? String {
                                movie.release = release
                            }
                            if let posterPath = result["poster_path"] as? String {
                                movie.posterPath = posterPath
                            }
                            
                            movies.append(movie)
                        }
                        
                        DispatchQueue.main.async {
                            completionHandler(movies, total, nil)
                        }
                        
                    case .failure(let error):
                        DispatchQueue.main.async {
                            completionHandler(nil, 0, error)
                        }
                    }
            }
        }
    }
}
