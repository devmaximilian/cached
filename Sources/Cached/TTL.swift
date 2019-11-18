//
//  File.swift
//  
//
//  Created by Maximilian Wendel on 2019-11-18.
//

import Foundation

public enum TTL {
    case infinite
    case seconds(Int)
    case minutes(Int)
    case hours(Int)
    case days(Int)
    case weeks(Int)
    case months(Int)
    
    public var interval: TimeInterval {
        switch self {
        case .infinite:
            return 0
        case .seconds(let value):
            return Double(value)
        case .minutes(let value):
            return Double(value * 60)
        case .hours(let value):
            return Double(value * 60 * 60)
        case .days(let value):
            return Double(value * 60 * 60 * 24)
        case .weeks(let value):
            return Double(value * 60 * 60 * 24 * 7)
        case .months(let value):
            return Double(value * 60 * 60 * 24 * 7 * 4)
        }
    }
}
