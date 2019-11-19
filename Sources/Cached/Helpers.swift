//
// Helpers.swift
//
// Copyright (c) 2019 Maximilian Wendel
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED  AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

/// An extension to `Encodable` used to encode objects
public extension Encodable {
    /// A `Data` representation of an `Encodable` type
    var data: Data? {
        return try? JSONEncoder().encode(self)
    }
}

/// An extension to `Data` used to decode `Data`
public extension Data {
    /// Decodes the `Data` to the specified type
    /// - Parameter type: The type to decode to
    func decode<T: Decodable>(type: T.Type) -> T? {
        return try? JSONDecoder().decode(type, from: self)
    }
}

/// A class for managing the on-disk cache and it's metadata
class Cache {
    // MARK: Public properties

    /// A shared singleton instance
    public static let shared: Cache = .init()

    // MARK: Initializers

    /// Initializes a new `Cache` instance
    private init() {}

    // MARK: Private properties

    /// The cache directory `URL`
    private var cacheDirectory: URL {
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return URL(fileURLWithPath: "./")
        }
        return url
    }

    /// Resolves a filename to a valid `URL`
    /// - Parameter filename: The file to resolve
    private func resolve(filename: String) -> URL {
        return self.cacheDirectory.appendingPathComponent(filename, isDirectory: false)
    }

    /// Purges stale cache
    /// - Parameter key: The cache-key to check
    private func purgeStale(key: String) {
        // Get the cache's metadata
        guard let data = FileManager.default.contents(atPath: resolve(filename: "\(key).cache").path) else {
            return
        }

        // ... and decode it
        guard let meta = data.decode(type: CacheMeta.self) else {
            return
        }

        // Skip purging cache if it does not expire
        guard meta.expires.timeIntervalSince1970 > 0 else {
            return
        }

        // Purge cache if it has gone stale
        if meta.expires < Date() {
            try? FileManager.default.removeItem(at: self.resolve(filename: "\(key).json"))
            try? FileManager.default.removeItem(at: self.resolve(filename: "\(key).cache"))
        }
    }

    /// Creates a metadata-file for a cache-key and it's value
    /// - Parameters:
    ///   - key: The cache-key
    ///   - value: The cached value
    ///   - ttl: The cache's Time To Live
    private func createMeta(key: String, value: Codable, ttl: TimeInterval) {
        let url = self.resolve(filename: "\(key).cache")
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
        FileManager.default.createFile(atPath: url.path, contents: CacheMeta(ttl: ttl, value: value).data, attributes: nil)
    }

    // MARK: Public methods

    /// Creates a new cache
    /// - Parameters:
    ///   - key: The cache-key to use for the stored value
    ///   - value: The value to store
    ///   - ttl: The cache's Time To Live
    @discardableResult
    func create(key: String, value: Codable, ttl: TimeInterval) -> Bool {
        let url = self.resolve(filename: "\(key).json")
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
        self.createMeta(key: key, value: value, ttl: ttl)
        return FileManager.default.createFile(atPath: url.path, contents: value.data, attributes: nil)
    }

    /// Reads a value from cache using a cache-key
    /// - Parameter key: The cache-key to use for reading the value
    func read<T: Decodable>(key: String) -> T? {
        // Check and purge the data if it has gone stale
        self.purgeStale(key: key)

        // Read the value from the cache-key
        guard let data = FileManager.default.contents(atPath: resolve(filename: "\(key).json").path) else {
            return nil
        }

        // Decode the value and return it
        return data.decode(type: T.self)
    }
}
