//
// TTL.swift
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

/// A helper to indicate the Time To Live for a given cache
public enum TTL {
    /// The cache does not expire
    case infinite

    /// The cache is valid for a given number of seconds
    case seconds(Int)

    /// The cache is valid for a number of given minutes
    case minutes(Int)

    /// The cache is valid for a number of given hours
    case hours(Int)

    /// The cache is valid for a number of given days
    case days(Int)

    /// The cache is valid for a number of given weeks
    case weeks(Int)

    /// The cache is valid for a number of given months
    case months(Int)

    /// Transforms the `TTL` instance into an instance of `TimeInterval`
    public var interval: TimeInterval {
        switch self {
        case .infinite:
            return 0
        case let .seconds(value):
            return Double(value)
        case let .minutes(value):
            return Double(value * 60)
        case let .hours(value):
            return Double(value * 60 * 60)
        case let .days(value):
            return Double(value * 60 * 60 * 24)
        case let .weeks(value):
            return Double(value * 60 * 60 * 24 * 7)
        case let .months(value):
            return Double(value * 60 * 60 * 24 * 7 * 4)
        }
    }
}
