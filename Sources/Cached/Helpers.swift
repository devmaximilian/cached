//
//  File.swift
//  
//
//  Created by Maximilian Wendel on 2019-11-18.
//

import Foundation

public extension Encodable {
    var data: Data? {
        return try? JSONEncoder().encode(self)
    }
}

public extension Data {
    func decode<T: Decodable>(type: T.Type) -> T? {
        return try? JSONDecoder().decode(type, from: self)
    }
}

class Cache {
    
    // MARK: Public properties
    
    public static let shared: Cache = .init()
    
    // MARK: Private properties
    
    private init() {}
    
    private var cacheDirectory: URL {
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return URL(fileURLWithPath: "./")
        }
        return url
    }
    
    private func resolve(filename: String) -> URL {
        return self.cacheDirectory.appendingPathComponent(filename, isDirectory: false)
    }
    
    private func purgeStale(key: String) {
        guard let data = FileManager.default.contents(atPath: resolve(filename: "\(key).cache").path) else {
            return
        }
        
        guard let meta = data.decode(type: CacheMeta.self) else {
            return
        }
        
        guard meta.expires.timeIntervalSince1970 > 0 else {
            return
        }
        
        if meta.expires < Date() {
            try? FileManager.default.removeItem(at: resolve(filename: "\(key).json"))
            try? FileManager.default.removeItem(at: resolve(filename: "\(key).cache"))
        }
    }
    
    private func createMeta(key: String, value: Codable, ttl: TimeInterval) {
        let url = resolve(filename: "\(key).cache")
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
        FileManager.default.createFile(atPath: url.path, contents: CacheMeta(ttl: ttl, value: value).data, attributes: nil)
    }
    
    // MARK: Public methods
    
    @discardableResult
    func create(key: String, value: Codable, ttl: TimeInterval) -> Bool {
        let url = resolve(filename: "\(key).json")
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
        self.createMeta(key: key, value: value, ttl: ttl)
        return FileManager.default.createFile(atPath: url.path, contents: value.data, attributes: nil)
    }
    
    func read<T: Decodable>(key: String) -> T? {
        // Purge the data if it has gone stale
        self.purgeStale(key: key)
        
        guard let data = FileManager.default.contents(atPath: resolve(filename: "\(key).json").path) else {
            return nil
        }
        return data.decode(type: T.self)
    }
}
