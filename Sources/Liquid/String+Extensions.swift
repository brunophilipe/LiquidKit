//
//  Extensions.swift
//  Liquid
//
//  Created by YourtionGuo on 29/06/2017.
//
//
extension String {
    func findFirstNot(character: Character) -> String.Index? {
        var index = startIndex
        
        while index != endIndex {
            if character != self[index] {
                return index
            }
            index = self.index(after: index)
        }
        
        return nil
    }
    
    func findLastNot(character: Character) -> String.Index? {
        var index = self.index(before: endIndex)
        
        while index != startIndex {
            if character != self[index] {
                return self.index(after: index)
            }
            index = self.index(before: index)
        }
        
        return nil
    }
    
    func trim(character: Character) -> String {
        let first = findFirstNot(character: character) ?? startIndex
        let last = findLastNot(character: character) ?? endIndex
        return self[first..<last]
    }
}

extension String {
    /// Split a string by a separator leaving quoted phrases together
    func smartSplit(separator: Character = " ") -> [String] {
        var word = ""
        var components: [String] = []
        var separate: Character = separator
        var singleQuoteCount = 0
        var doubleQuoteCount = 0
        
        for character in self.characters {
            if character == "'" { singleQuoteCount += 1 }
            else if character == "\"" { doubleQuoteCount += 1 }
            
            if character == separate {
                
                if separate != separator {
                    word.append(separate)
                } else if singleQuoteCount % 2 == 0 && doubleQuoteCount % 2 == 0 && !word.isEmpty {
                    components.append(word)
                    word = ""
                }
                
                separate = separator
            } else {
                if separate == separator && (character == "'" || character == "\"") {
                    separate = character
                }
                word.append(character)
            }
        }
        
        if !word.isEmpty {
            components.append(word)
        }
        
        return components
    }
}
