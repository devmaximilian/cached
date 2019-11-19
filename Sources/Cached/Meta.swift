//
// Meta.swift
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

/// The cache-meta structure
struct CacheMeta: Codable {
    /// The cache's expiry date
    let expires: Date

    /// The cache's Time To Live
    let ttl: TimeInterval

    /// The value's type
    /// - Note: Will be used to warn if two instances use the same cache-key and different value types
    let valueType: String

    /// Initializes a new `CacheMeta` instance
    /// - Parameters:
    ///   - ttl: The cache's Time To Live
    ///   - value: The value to cache
    init(ttl: TimeInterval, value: Codable) {
        self.expires = ttl > 0 ? Date(timeIntervalSinceNow: ttl) : Date(timeIntervalSince1970: 0)
        self.ttl = ttl
        self.valueType = String(describing: type(of: value))
    }
}
