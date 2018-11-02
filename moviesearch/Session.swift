//
//  Session.swift
//  moviesearch
//
//  Created by Ilya Kalinin on 02/11/2018.
//  Copyright © 2018 Ilya Kalinin. All rights reserved.
//

import Foundation

class Session {
    
    private static let sessionKey = "session"
    
    class func save(session: String?) {
        let defaults = UserDefaults.standard
        defaults.set(session, forKey: sessionKey)
        print("Saved session: \(defaults.object(forKey: sessionKey) ?? "no session")")
    }
    
    class func getSession() -> String? {
        let defaults = UserDefaults.standard
        guard let session = defaults.object(forKey: sessionKey) as? String else {
            return nil
        }
        return session
    }
}
