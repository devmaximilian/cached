//
// Cached.swift
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
import os

/// The property wrapper used to indicate that a value should be cached
///
/// ```
/// struct Article: Codable {
///     let title: String
///     let description: String
/// }
///
/// class Service {
///     init() {}
///
///     @Cached(key: "articles", defaultValue: [], ttl: .minutes(30))
///     var articles: [Article]
/// }
@propertyWrapper
public struct Cached<T: Codable> {
    private let defaultValue: T
    private let ttl: TimeInterval
    private let key: String
    private let log: OSLog

    /// Initializes a new `Cached` instance
    /// - Parameters:
    ///   - key: The cache-key to use
    ///   - defaultValue: The default value for `T`
    ///   - ttl: The cache's Time To Live
    /// - Precondition: The cache-key **must be unique** for every instance of `Cached<_>`
    public init(key: String, defaultValue: T, ttl: TTL = .seconds(60)) {
        self.key = key
        self.ttl = ttl.interval
        self.defaultValue = defaultValue
        self.log = OSLog(subsystem: "cached", category: "key-\(key)")
    }

    /// The wrapped value `T`
    /// - Note: Updating the value will cause it to be updated
    public var wrappedValue: T {
        get {
            os_log("Reading value for key %@", log: self.log, type: .info, self.key)
            return Cache.shared.read(key: self.key) ?? self.defaultValue
        }
        set {
            os_log("Writing value for key %@", log: self.log, type: .info, self.key)
            Cache.shared.create(key: self.key, value: newValue, ttl: self.ttl)
        }
    }
}
