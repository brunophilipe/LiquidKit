//
//  Parser.swift
//  Liquid
//
//  Created by YourtionGuo on 28/06/2017.
//
//

import Foundation

/// A class for parsing an array of tokens and converts them into a collection of Node's
public class TokenParser {
    
    fileprivate var tokens: [Token]
    fileprivate let context: Context
    
    public init(tokens: [Token], context: Context) {
        self.tokens = tokens
        self.context = context
    }
    
    /// Parse the given tokens into nodes
    public func parse() -> [String] {
        return parse(nil)
    }
    
    public func parse(_ parse_until:((_ parser:TokenParser, _ token:Token) -> (Bool))?) -> [String] {
        var nodes = [String]()
        
        while tokens.count > 0 {
            let token = nextToken()!
            
            switch token {
            case .text(let text):
                nodes.append(text)
            case .variable:
                nodes.append(compileFilter(token.contents))
            case .tag:
                continue
            }
        }
        
        return nodes
    }
    
    public func nextToken() -> Token? {
        if tokens.count > 0 {
            return tokens.remove(at: 0)
        }
        
        return nil
    }
    
    public func compileFilter(_ token: String) -> String {
        return self.context.dictionaries[token] as! String
    }
}
