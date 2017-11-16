//
//  Lexer.swift
//  Liquid
//
//  Created by YourtionGuo on 28/06/2017.
//
//

import Foundation

struct Lexer {
    let templateString: String
    
    init(templateString: String) {
        self.templateString = templateString
    }
    
    func createToken(string: String) -> Token {
        func strip() -> String {
            let start = string.index(string.startIndex, offsetBy: 2)
            let end = string.index(string.endIndex, offsetBy: -2)
          return String(string[start..<end]).trim(character: " ")
        }
        
        if string.hasPrefix("{{") {
            return .variable(value: strip())
        } else if string.hasPrefix("{%") {
            return .tag(value: strip())
        }
        
        return .text(value: string)
    }
    
    /// Returns an array of tokens from a given template string.
    func tokenize() -> [Token] {
        var tokens: [Token] = []
        
        let scanner = Scanner(templateString)
        
        let map = [
            "{{": "}}",
            "{%": "%}",
            ]
        
        while !scanner.isEmpty {
            if let text = scanner.scan(until: ["{{", "{%"]) {
                if !text.1.isEmpty {
                    tokens.append(createToken(string: text.1))
                }
                
                let end = map[text.0]!
                let result = scanner.scan(until: end, returnUntil: true)
                tokens.append(createToken(string: result))
            } else {
                tokens.append(createToken(string: scanner.content))
                scanner.content = ""
            }
        }
        
        return tokens
    }
}


class Scanner {
    var content: String
    
    init(_ content: String) {
        self.content = content
    }
    
    var isEmpty: Bool {
        return content.isEmpty
    }
    
    func scan(until: String, returnUntil: Bool = false) -> String {
        if until.isEmpty {
            return ""
        }
        
        var index = content.startIndex
        while index != content.endIndex {
            let substring = String(content[index...])
            
            if substring.hasPrefix(until) {
                let result = String(content[..<index])
                content = substring
                
                if returnUntil {
                    content = String(content[until.endIndex...])
                    return result + until
                }
                
                return result
            }
            
            index = content.index(after: index)
        }
        
        content = ""
        return ""
    }
    
    func scan(until: [String]) -> (String, String)? {
        if until.isEmpty {
            return nil
        }
        
        var index = content.startIndex
        while index != content.endIndex {
            let substring = String(content[index...])
            for string in until {
                if substring.hasPrefix(string) {
                    let result = String(content[..<index])
                    content = substring
                    return (string, result)
                }
            }
            
            index = content.index(after: index)
        }
        
        return nil
    }
}
