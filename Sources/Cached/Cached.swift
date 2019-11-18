import Foundation
import os

@propertyWrapper
struct Cached<T: Codable> {
    let defaultValue: T
    let ttl: TimeInterval
    let key: String
    let log: OSLog
    
    init(key: String, defaultValue: T, ttl: TTL = .seconds(60)) {
        self.key = key
        self.ttl = ttl.interval
        self.defaultValue = defaultValue
        self.log = OSLog(subsystem: "cached", category: "key-\(key)")
        
        guard let value: T = Cache.shared.read(key: key) else {
            return
        }
        print(value)
    }
    
    var wrappedValue: T {
        get {
            os_log("Reading value for key %@", log: log, type: .info, key)
            return Cache.shared.read(key: key) ?? defaultValue
        }
        set {
            os_log("Writing value for key %@", log: log, type: .info, key)
            Cache.shared.create(key: key, value: newValue, ttl: ttl)
        }
    }
}
