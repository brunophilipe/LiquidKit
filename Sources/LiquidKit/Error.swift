//
//  Error.swift
//  Liquid
//
//  Created by YourtionGuo on 29/06/2017.
//
//

public struct TemplateSyntaxError : Error, Equatable, CustomStringConvertible {
    public let description:String
    
    public init(_ description:String) {
        self.description = description
    }
    
    public static func ==(lhs:TemplateSyntaxError, rhs:TemplateSyntaxError) -> Bool {
        return lhs.description == rhs.description
    }
}
