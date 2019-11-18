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
            try? FileManager.default.removeItem(at: self.resolve(filename: "\(key).json"))
            try? FileManager.default.removeItem(at: self.resolve(filename: "\(key).cache"))
        }
    }

    private func createMeta(key: String, value: Codable, ttl: TimeInterval) {
        let url = self.resolve(filename: "\(key).cache")
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
        FileManager.default.createFile(atPath: url.path, contents: CacheMeta(ttl: ttl, value: value).data, attributes: nil)
    }

    // MARK: Public methods

    @discardableResult
    func create(key: String, value: Codable, ttl: TimeInterval) -> Bool {
        let url = self.resolve(filename: "\(key).json")
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
