//
//  Token.swift
//  Liquid
//
//  Created by YourtionGuo on 28/06/2017.
//
//

import Foundation

public enum Token : Equatable {
    
    /// A token representing a piece of text.
    case text(value: String)
    
    /// A token representing a variable.
    case variable(value: String)
    
    /// A token representing a template tag.
    case tag(value: String)

    public var contents: String {
        switch self {
        case .text(let value):
            return value
        case .variable(let value):
            return value
        case .tag(let value):
            return value
        }
    }
    
    public static func ==(lhs: Token, rhs: Token) -> Bool {
        switch (lhs, rhs) {
        case (.text(let lhsValue), .text(let rhsValue)):
            return lhsValue == rhsValue
        case (.variable(let lhsValue), .variable(let rhsValue)):
            return lhsValue == rhsValue
        case (.tag(let lhsValue), .tag(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}
