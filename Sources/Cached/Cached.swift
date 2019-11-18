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
            os_log("Reading value for key %@", log: self.log, type: .info, self.key)
            return Cache.shared.read(key: self.key) ?? self.defaultValue
        }
        set {
            os_log("Writing value for key %@", log: self.log, type: .info, self.key)
            Cache.shared.create(key: self.key, value: newValue, ttl: self.ttl)
        }
    }
}
