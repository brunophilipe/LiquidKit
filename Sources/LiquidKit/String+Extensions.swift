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
        let first = findFirstNot(character: character) ?? endIndex
        let last = findLastNot(character: character) ?? endIndex
      return String(self[first..<last])
    }

	var trimmingWhitespaces: String {
		return trimmingCharacters(in: .whitespacesAndNewlines)
	}

	public func firstIndex(reverse: Bool, where predicate: (Character) throws -> Bool) rethrows -> String.Index?
	{
		guard reverse, count > 0 else
		{
			return try firstIndex(where: predicate)
		}

		var index = self.index(before: endIndex)

		repeat
		{
			if try predicate(self[index])
			{
				return index
			}

			index = self.index(before: index)
		}
		while index != startIndex

		return nil
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
        
        for character in self {
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

	func split(boundary: String, maxSplits: Int = Int.max, omittingEmptySubsequences: Bool = false) -> [Substring]
	{
		var splits = [Substring]()
		var scannedIndex = startIndex

		while let separatorRange = range(of: boundary, range: scannedIndex..<endIndex), splits.count < maxSplits
		{
			let substringRange = scannedIndex..<separatorRange.lowerBound
			let substring = self[substringRange]

			if !(omittingEmptySubsequences && substring.count == 0)
			{
				splits.append(substring)
			}

			scannedIndex = separatorRange.upperBound
		}

		if splits.count < maxSplits - 1
		{
			let remainderSubstring = self[scannedIndex..<endIndex]

			if !(omittingEmptySubsequences && remainderSubstring.count == 0)
			{
				splits.append(remainderSubstring)
			}
		}

		return splits
	}

	var splitKeyPath: (key: String, index: Int?, remainder: String?)?
	{
		let nsKeyPath = self as NSString
		let pattern = "(\\w+)(\\[(\\d+)\\])?\\.?"

		let regex = try! NSRegularExpression(pattern: pattern, options: [])

		guard
			let match = regex.firstMatch(in: self, options: [], range: nsKeyPath.fullRange),
			match.range(at: 1).location != NSNotFound
		else
		{
			return nil
		}

		let key = nsKeyPath.substring(with: match.range(at: 1))
		let remainder: String?

		if match.range.upperBound < nsKeyPath.length
		{
			remainder = nsKeyPath.substring(from: match.range.upperBound)
		}
		else
		{
			remainder = nil
		}

		if match.range(at: 3).location != NSNotFound, let index = Int(nsKeyPath.substring(with: match.range(at: 3)))
		{
			return (key, index, remainder)
		}
		else
		{
			return (key, nil, remainder)
		}
	}
}

extension NSString
{
	var fullRange: NSRange
	{
		return NSMakeRange(0, length)
	}
}
