//
//  Filter.swift
//  Liquid
//
//  Created by Bruno Philipe on 12/09/18.
//

import Foundation
import STRFTimeFormatter
import HTMLEntities

/// A class representing a filter
open class Filter
{
	/// Keyword used to identify the filter.
	let identifier: String

	/// Function that transforms the input string.
	let lambda: ((Token.Value, [Token.Value]) -> Token.Value)

	/// Filter constructor.
	init(identifier: String, lambda: @escaping (Token.Value, [Token.Value]) -> Token.Value) {
		self.identifier = identifier
		self.lambda = lambda
	}
}

extension Filter {
	static let abs = Filter(identifier: "abs") { (input, _) -> Token.Value in
		guard let decimal = input.decimalValue else {
			return input
		}
		
		return .decimal(Swift.abs(decimal))
	}

	static let append = Filter(identifier: "append") { (input, parameters) -> Token.Value in
		guard let stringParameter = parameters.first?.stringValue else {
			return input
		}

		return .string(input.stringValue + stringParameter)
	}

	static let atLeast = Filter(identifier: "at_least") { (input, parameters) -> Token.Value in
		guard
			let inputDecimal = input.decimalValue,
			let parameterDecimal = parameters.first?.decimalValue
		else {
			return input
		}

		return .decimal(max(inputDecimal, parameterDecimal))
	}

	static let atMost = Filter(identifier: "at_most") { (input, parameters) -> Token.Value in
		guard
			let inputDecimal = input.decimalValue,
			let parameterDecimal = parameters.first?.decimalValue
		else {
				return input
		}

		return .decimal(min(inputDecimal, parameterDecimal))
	}

	static let capitalize = Filter(identifier: "capitalize") { (input, _) -> Token.Value in

		let inputString = input.stringValue
		
		guard inputString.count > 0 else {
			return input
		}

		var firstWord: String!
		var firstWordRange: Range<String.Index>!

		inputString.enumerateSubstrings(in: inputString.startIndex..., options: .byWords, { (word, range, _, stop) in
			firstWord = word
			firstWordRange = range
			stop = true
		})

		return .string(inputString.replacingCharacters(in: firstWordRange, with: firstWord.localizedCapitalized))
	}

	static let ceil = Filter(identifier: "ceil")
	{
		(input, _) -> Token.Value in

		guard let inputDouble = input.doubleValue else
		{
				return input
		}

		return .decimal(Decimal(Int(Darwin.ceil(inputDouble))))
	}

	// static let compact: Filter
	// static let concat: Filter

	static let date = Filter(identifier: "date") { (input, parameters) -> Token.Value in

		guard let formatString = parameters.first?.stringValue else {
			return input
		}
		
		let inputString = input.stringValue

		var date: Date? = nil

		if inputString == "today" || inputString == "now" {
			date = Date()
		} else {
			let styles: [DateFormatter.Style] = [.none, .short, .medium, .long, .full]
			let dateFormatter = DateFormatter()

			for dateStyle in styles {
				for timeStyle in styles {
					dateFormatter.dateStyle = dateStyle
					dateFormatter.timeStyle = timeStyle

					dateFormatter.locale = Locale.current

					if let parsedDate = dateFormatter.date(from: inputString) {
						date = parsedDate
						break
					}

					dateFormatter.locale = Locale(identifier: "en_US")

					if let parsedDate = dateFormatter.date(from: inputString) {
						date = parsedDate
						break
					}
				}

				if date != nil {
					break
				}
			}
		}

		guard date != nil else {
			return input
		}

		let strFormatter = STRFTimeFormatter()
		strFormatter.setFormatString(formatString)

		if let dateString = strFormatter.string(from: date!) {
			return .string(dateString)
		}
		
		return input
	}

	static let `default` = Filter(identifier: "default") { (input, parameters) -> Token.Value in
		
		guard let defaultParameter = parameters.first else {
			return input
		}
		
		if input.isFalsy || input.isEmptyString {
			return defaultParameter
		}
		
		return input
	}
	
	static let dividedBy = Filter(identifier: "divided_by")
	{
		(input, parameters) -> Token.Value in

		guard let dividendDouble = input.doubleValue, let divisor = parameters.first else
		{
			return input
		}

		switch divisor
		{
		case .integer(let divisorInt):
			return .integer(Int(Darwin.floor(dividendDouble / Double(divisorInt))))

		case .decimal:
			return .decimal(Decimal(dividendDouble / divisor.doubleValue!))

		default:
			return input
		}
	}

	static let downcase = Filter(identifier: "downcase")
	{
		(input, _) -> Token.Value in

		guard case .string(let inputString) = input else {
			return input
		}

		return .string(inputString.lowercased())
	}

	static let escape = Filter(identifier: "escape")
	{
		(input, parameters) -> Token.Value in

		return .string(input.stringValue.htmlEscape(decimal: true, useNamedReferences: true))
	}

	static let escapeOnce = Filter(identifier: "escape_once")
	{
		(input, parameters) -> Token.Value in

		return .string(input.stringValue.htmlUnescape().htmlEscape(decimal: true, useNamedReferences: true))
	}

//	static let first: Filter

	static let floor = Filter(identifier: "floor")
	{
		(input, _) -> Token.Value in

		guard let inputDouble = input.doubleValue else
		{
			return input
		}

		return .decimal(Decimal(Int(Darwin.floor(inputDouble))))
	}

	static let join = Filter(identifier: "join")
	{
		(input, parameters) -> Token.Value in

		guard
			let firstParameter = parameters.first,
			case .string(let glue) = firstParameter,
			case .array(let inputArray) = input
		else
		{
			return input
		}

		return .string(inputArray.map({ $0.stringValue }).joined(separator: glue))
	}

//	static let last: Filter

	static let leftStrip = Filter(identifier: "lstrip")
	{
		(input, _) -> Token.Value in

		guard case .string(let inputString) = input else
		{
			return input
		}

		let charset = CharacterSet.whitespacesAndNewlines
		let firstNonBlankIndex = inputString.firstIndex()
		{
			char -> Bool in

			guard char.unicodeScalars.count == 1, let unichar = char.unicodeScalars.first else
			{
				return true
			}

			return !charset.contains(unichar)
		}

		guard let index = firstNonBlankIndex else
		{
			return input
		}

		return .string(String(inputString[index...]))
	}

//	static let map: Filter

	static let minus = Filter(identifier: "minus")
	{
		(input, parameters) -> Token.Value in

		guard let decimalInput = input.decimalValue, let decimalParameter = parameters.first?.decimalValue else
		{
			return input
		}

		return .decimal(decimalInput - decimalParameter)
	}

	static let modulo = Filter(identifier: "modulo")
	{
		(input, parameters) -> Token.Value in

		guard let doubleInput = input.doubleValue, let doubleParameter = parameters.first?.doubleValue else
		{
			return input
		}

		return .decimal(Decimal(doubleInput.truncatingRemainder(dividingBy: doubleParameter)))
	}

	static let newlineToBr = Filter(identifier: "newline_to_br")
	{
		(input, _) -> Token.Value in

		guard case .string(let inputString) = input else
		{
			return input
		}

		return .string(inputString.replacingOccurrences(of: "\r\n", with: "<br />")
								  .replacingOccurrences(of: "\n", with: "<br />"))
	}

	static let plus = Filter(identifier: "plus")
	{
		(input, parameters) -> Token.Value in

		guard let decimalInput = input.decimalValue, let decimalParameter = parameters.first?.decimalValue else
		{
			return input
		}

		return .decimal(decimalInput + decimalParameter)
	}

	static let prepend = Filter(identifier: "prepend")
	{
		(input, parameters) -> Token.Value in

		guard let stringParameter = parameters.first?.stringValue else
		{
			return input
		}

		return .string(stringParameter + input.stringValue)
	}

	static let remove = Filter(identifier: "remove")
	{
		(input, parameters) -> Token.Value in

		guard let needle = parameters.first?.stringValue else
		{
			return input
		}

		return .string(input.stringValue.replacingOccurrences(of: needle, with: ""))
	}
	
	static let removeFirst = Filter(identifier: "remove_first")
	{
		(input, parameters) -> Token.Value in

		guard let needle = parameters.first?.stringValue else
		{
			return input
		}

		let inputString = input.stringValue
		guard let needleRange = inputString.range(of: needle) else
		{
			return input
		}

		return .string(inputString.replacingCharacters(in: needleRange, with: ""))
	}

	static let replace = Filter(identifier: "replace")
	{
		(input, parameters) -> Token.Value in

		guard parameters.count == 2 else
		{
			return input
		}

		let needle		= parameters[0].stringValue
		let replacement	= parameters[1].stringValue

		return .string(input.stringValue.replacingOccurrences(of: needle, with: replacement))
	}

	static let replaceFirst = Filter(identifier: "replace_first")
	{
		(input, parameters) -> Token.Value in

		guard parameters.count == 2 else
		{
			return input
		}

		let needle		= parameters[0].stringValue
		let replacement	= parameters[1].stringValue
		let inputString	= input.stringValue

		guard let needleRange = inputString.range(of: needle) else
		{
			return input
		}

		return .string(inputString.replacingCharacters(in: needleRange, with: replacement))
	}

	static let reverse = Filter(identifier: "reverse")
	{
		(input, _) -> Token.Value in

		guard case .array(let inputArray) = input else
		{
			return input
		}

		return .array(inputArray.reversed())
	}

	static let round = Filter(identifier: "round")
	{
		(input, parameters) -> Token.Value in

		guard let inputDouble = input.doubleValue else
		{
			return input
		}

		if let decimalCount = parameters.first?.integerValue
		{
			return .decimal(Decimal(inputDouble.truncatingDecimals(to: decimalCount)))
		}
		else
		{
			return .integer(Int(Darwin.round(inputDouble)))
		}
	}

	static let rightStrip = Filter(identifier: "rstrip")
	{
		(input, parameters) -> Token.Value in

		guard case .string(let inputString) = input else
		{
			return input
		}

		let charset = CharacterSet.whitespacesAndNewlines
		let lastNonBlankIndex = inputString.firstIndex(reverse: true)
		{
			char -> Bool in

			guard char.unicodeScalars.count == 1, let unichar = char.unicodeScalars.first else
			{
				return true
			}

			return !charset.contains(unichar)
		}

		guard let index = lastNonBlankIndex else
		{
			return input
		}

		return .string(String(inputString[...index]))
	}

	static let size = Filter(identifier: "size")
	{
		(input, _) -> Token.Value in

		switch input
		{
		case .string(let string): return .integer(string.count)
		case .array(let array): return .integer(array.count)
		default:
			return .nil
		}
	}

	static let slice = Filter(identifier: "slice")
	{
		(input, parameters) -> Token.Value in

		guard
			case .string(let stringInput) = input,
			(1...2).contains(parameters.count),
			let slice = parameters[0].integerValue
		else
		{
			return .nil
		}

		let startIndex: String.Index
		let splice: Substring

		if slice >= 0
		{
			startIndex = stringInput.index(stringInput.startIndex, offsetBy: slice)
		}
		else
		{
			startIndex = stringInput.index(stringInput.endIndex, offsetBy: slice)
		}

		let length = parameters.count == 2 ? parameters[1].integerValue ?? 1 : 1
		let effectiveLength = min(length, stringInput.distance(from: startIndex, to: stringInput.endIndex))
		let endIndex = stringInput.index(startIndex, offsetBy: effectiveLength)

		return .string(String(stringInput[startIndex..<endIndex]))
	}

	static let sort = Filter(identifier: "sort")
	{
		(input, _) -> Token.Value in

		guard case .array(let arrayInput) = input else
		{
			return input
		}

		return .array(arrayInput.map({ $0.stringValue }).sorted().map({ .string($0) }))
	}

	static let sortNatural = Filter(identifier: "sort_natural")
	{
		(input, _) -> Token.Value in

		guard case .array(let arrayInput) = input else
		{
			return input
		}

		func naturallyAscending(_ s1: String, _ s2: String) -> Bool
		{
			return s1.localizedCaseInsensitiveCompare(s2) == .orderedAscending
		}

		return .array(arrayInput.map({ $0.stringValue }).sorted(by: naturallyAscending).map({ .string($0) }))
	}

	static let split = Filter(identifier: "split")
	{
		(input, parameters) -> Token.Value in

		guard
			let firstParameter = parameters.first,
			case .string(let boundary) = firstParameter,
			case .string(let inputString) = input
		else
		{
			return input
		}

		if boundary.count == 0
		{
			// Special case: Empty boundary means we need to split into an array of strings holding each char.
			return .array(inputString.map({ Token.Value.string(String($0)) }))
		}

		return .array(inputString.split(boundary: boundary).map({ Token.Value.string(String($0)) }))
	}

	static let strip = Filter(identifier: "strip")
	{
		(input, _) -> Token.Value in

		guard case .string(let inputString) = input else
		{
			return input
		}

		return .string(inputString.trimmingWhitespaces)
	}

	static let stripHTML = Filter(identifier: "strip_html")
	{
		(input, _) -> Token.Value in

		let htmlRegex = "<[^>]+>"
		return .string(input.stringValue.replacingOccurrences(of: htmlRegex, with: "", options: .regularExpression))
	}

	static let stripNewlines = Filter(identifier: "strip_newlines")
	{
		(input, _) -> Token.Value in

		return .string(input.stringValue.replacingOccurrences(of: "\r\n", with: "")
										.replacingOccurrences(of: "\n", with: ""))
	}

	static let times = Filter(identifier: "times")
	{
		(input, parameters) -> Token.Value in

		guard let decimalInput = input.decimalValue, let decimalParameter = parameters.first?.decimalValue else
		{
			return input
		}

		return .decimal(decimalInput * decimalParameter)
	}

	static let truncate = Filter(identifier: "truncate")
	{
		(input, parameters) -> Token.Value in

		guard (1...2).contains(parameters.count), let length = parameters[0].integerValue else
		{
			return input
		}

		let inputString = input.stringValue

		if length >= inputString.count
		{
			return .string(inputString)
		}

		let suffix = parameters.count == 2 ? parameters[1].stringValue : "..."

		return .string(inputString.prefix(max(length - suffix.count, 0)) + suffix)
	}

	static let truncateWords = Filter(identifier: "truncatewords")
	{
		(input, parameters) -> Token.Value in

		guard (1...2).contains(parameters.count), let wordCount = parameters[0].integerValue else
		{
			return input
		}

		let inputString = input.stringValue
		let suffix = parameters.count == 2 ? parameters[1].stringValue : "..."
		var lastEnumeratedIndex = inputString.startIndex
		var words = [String]()

		let _ = inputString.enumerateSubstrings(in: inputString.startIndex..., options: [.localized, .byWords])
		{
			(word, range, _, stop) in

			guard let word = word else
			{
				return
			}

			words.append(word)
			lastEnumeratedIndex = range.upperBound

			if words.count >= wordCount
			{
				stop = true
			}
		}

		if lastEnumeratedIndex == inputString.endIndex
		{
			return .string(inputString)
		}

		return .string(words.joined(separator: " ") + suffix)
	}

	static let uniq = Filter(identifier: "uniq")
	{
		(input, _) -> Token.Value in

		guard case .array(let inputArray) = input else
		{
			return input
		}

		return .array(NSOrderedSet(array: inputArray).array.compactMap({ $0 as? Token.Value }))
	}

	static let upcase = Filter(identifier: "upcase")
	{
		(input, _) -> Token.Value in

		return .string(input.stringValue.uppercased())
	}
	
	static let urlDecode = Filter(identifier: "url_decode")
	{
		(input, _) -> Token.Value in

		guard let decodedString = input.stringValue.removingPercentEncoding else
		{
			return .nil
		}

		return .string(decodedString.replacingOccurrences(of: "+", with: " "))
	}

	static let urlEncode = Filter(identifier: "url_encode")
	{
		(input, _) -> Token.Value in

		let inputString = input.stringValue.replacingOccurrences(of: " ", with: "+")

		// Based on RFC3986: https://tools.ietf.org/html/rfc3986#page-13, and including the `+` char which was already
		// escaped above.
		let allowedCharset = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~/?+"))
		guard let encodedString = inputString.addingPercentEncoding(withAllowedCharacters: allowedCharset) else
		{
			return .nil
		}

		return .string(encodedString)
	}
}
