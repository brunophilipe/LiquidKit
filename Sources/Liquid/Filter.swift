//
//  Filter.swift
//  Liquid
//
//  Created by brunophilipe on 08/09/2018.
//
//

import Foundation

/// A class representing a template
open class Filter {

	/// Keyword used to identify the filter.
	let identifier: String

	/// Function that transforms the input string.
	let lambda: ((Value, [Value]) -> Value)

	/// Filter constructor.
	init(identifier: String, lambda: @escaping (Value, [Value]) -> Value) {
		self.identifier = identifier
		self.lambda = lambda
	}
	
	public enum Value
	{
		case `nil`
		case bool(Bool)
		case string(String)
		case number(Decimal)
		
		var stringValue: String
		{
			switch self
			{
			case .bool(_), .nil: return ""
			case .number(let number): return "\(number)"
			case .string(let string): return string
			}
		}
		
		var decimalValue: Decimal?
		{
			switch self
			{
			case .number(let number): return number
			case .string(let string): return Decimal(string: string)
			default:
				return nil
			}
		}
		
		var doubleValue: Double?
		{
			switch self
			{
			case .number(let number): return NSDecimalNumber(decimal: number).doubleValue
			case .string(let string): return Double(string)
			default:
				return nil
			}
		}
		
		/// Returns `true` if the receiver is either `.nil` or `.bool(false)`. Otherwise returns `false`.
		var isFalsy: Bool
		{
			switch self
			{
			case .bool(false), .nil:
				return true
				
			default:
				return false
			}
		}
		
		/// Returns `false` if the receiver is either `.nil` or `.bool(false)`. Otherwise returns `true`.
		var isTruthy: Bool
		{
			return !isFalsy
		}
		
		var isEmptyString: Bool
		{
			switch self
			{
			case .string(let string):
				return string.isEmpty
				
			default:
				return false
			}
		}
	}
}

extension Filter {
	static let abs = Filter(identifier: "abs") { (input, _) -> Value in
		guard let decimal = input.decimalValue else {
			return input
		}
		
		return .number(Swift.abs(decimal))
	}

	static let append = Filter(identifier: "append") { (input, parameters) -> Value in
		guard let stringParameter = parameters.first?.stringValue else {
			return input
		}

		return .string(input.stringValue + stringParameter)
	}

	static let atLeast = Filter(identifier: "at_least") { (input, parameters) -> Value in
		guard
			let inputDecimal = input.decimalValue,
			let parameterDecimal = parameters.first?.decimalValue
		else {
			return input
		}

		return .number(max(inputDecimal, parameterDecimal))
	}

	static let atMost = Filter(identifier: "at_most") { (input, parameters) -> Value in
		guard
			let inputDecimal = input.decimalValue,
			let parameterDecimal = parameters.first?.decimalValue
		else {
				return input
		}

		return .number(min(inputDecimal, parameterDecimal))
	}

	static let capitalize = Filter(identifier: "capitalize") { (input, _) -> Value in

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

	static let ceil = Filter(identifier: "ceil") { (input, _) -> Value in

		guard let inputDouble = input.doubleValue else {
				return input
		}

		return .number(Decimal(Int(Darwin.ceil(inputDouble))))
	}

	// static let compact: Filter
	// static let concat: Filter

	static let date = Filter(identifier: "date") { (input, parameters) -> Value in

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

	static let `default` = Filter(identifier: "default") { (input, parameters) -> Filter.Value in
		
		guard let defaultParameter = parameters.first else {
			return input
		}
		
		if input.isFalsy || input.isEmptyString {
			return defaultParameter
		}
		
		return input
	}
	
//	static let divided_by: Filter
//	static let downcase: Filter
//	static let escape: Filter
//	static let escape_once: Filter
//	static let first: Filter
//	static let floor: Filter
//	static let join: Filter
//	static let last: Filter
//	static let lstrip: Filter
//	static let map: Filter
//	static let minus: Filter
//	static let modulo: Filter
//	static let newline_to_br: Filter
//	static let plus: Filter
//	static let prepend: Filter
//	static let remove: Filter
//	static let remove_first: Filter
//	static let replace: Filter
//	static let replace_first: Filter
//	static let reverse: Filter
//	static let round: Filter
//	static let rstrip: Filter
//	static let size: Filter
//	static let slice: Filter
//	static let sort: Filter
//	static let sort_natural: Filter
//	static let split: Filter
//	static let strip: Filter
//	static let strip_html: Filter
//	static let strip_newlines: Filter
//	static let times: Filter
//	static let truncate: Filter
//	static let truncatewords: Filter
//	static let uniq: Filter
//	static let upcase: Filter
//	static let url_decode: Filter
//	static let url_encode: Filter
}
