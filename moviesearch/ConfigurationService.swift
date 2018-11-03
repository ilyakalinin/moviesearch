//
//  ConfigurationService.swift
//  moviesearch
//
//  Created by Ilya Kalinin on 02/11/2018.
//  Copyright © 2018 Ilya Kalinin. All rights reserved.
//

import Foundation
import Alamofire

class ConfigurationService {
    
    class func updateConfigurationIfNeed(completionHandler: @escaping (Error?) -> Void) {
        if Configuration.getImagePath() != nil {
            completionHandler(nil)
        } else {
            updateConfiguration(completionHandler: completionHandler)
        }
    }
    
    private class func updateConfiguration(completionHandler: @escaping (Error?) -> Void) {
        let url = Configuration.getServerURL() + "configuration"
        let parameters = ["api_key": Configuration.getApiKey()]
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let resultValue):
                    guard let data = resultValue as? [String: AnyObject],
                        let imageData = data["images"] as? [String: AnyObject],
                        let imagePath = imageData["base_url"] as? String,
                        let poster_sizes = imageData["poster_sizes"] as? [String],
                        let poster_small = poster_sizes.first
                        else {
                            DispatchQueue.main.async {
                                completionHandler(nil)
                            }
                            return
                    }
                    
                    Configuration.save(imagePath: imagePath + poster_small + "/")
                    
                    DispatchQueue.main.async {
                        completionHandler(nil)
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        completionHandler(error)
                    }
                }
        }
    }
}
