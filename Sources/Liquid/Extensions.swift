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
