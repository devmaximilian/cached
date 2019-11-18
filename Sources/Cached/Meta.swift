//
//  File.swift
//  
//
//  Created by Maximilian Wendel on 2019-11-18.
//

import Foundation

struct CacheMeta: Codable {
    let expires: Date
    let ttl: TimeInterval
    let valueType: String // Used to warn for type conflicts
    
    init(ttl: TimeInterval, value: Codable) {
        self.expires = ttl > 0 ? Date(timeIntervalSinceNow: ttl) : Date(timeIntervalSince1970: 0)
        self.ttl = ttl
        self.valueType = String(describing: type(of: value))
    }
}
