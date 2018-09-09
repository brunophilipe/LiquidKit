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
	let lambda: ((String, [String]) -> String)

	/// Filter constructor.
	init(identifier: String, lambda: @escaping (String, [String]) -> String) {
		self.identifier = identifier
		self.lambda = lambda
	}
}

extension Filter {
	static let abs = Filter(identifier: "abs") { (input, _) -> String in
		return "\(Swift.abs(Decimal(string: input) ?? 0))"
	}

	static let append = Filter(identifier: "append") { (input, parameters) -> String in
		guard let firstParameter = parameters.first else {
			return input
		}

		return input + firstParameter
	}

	static let atLeast = Filter(identifier: "at_least") { (input, parameters) -> String in
		guard
			let inputDecimal = Decimal(string: input),
			let firstParameter = parameters.first,
			let parameterDecimal = Decimal(string: firstParameter)
		else {
			return input
		}

		return "\(max(inputDecimal, parameterDecimal))"
	}

	static let atMost = Filter(identifier: "at_most") { (input, parameters) -> String in
		guard
			let inputDecimal = Decimal(string: input),
			let firstParameter = parameters.first,
			let parameterDecimal = Decimal(string: firstParameter)
		else {
				return input
		}

		return "\(min(inputDecimal, parameterDecimal))"
	}

	static let capitalize = Filter(identifier: "capitalize") { (input: String, _) -> String in

		guard input.count > 0 else {
			return input
		}

		var firstWord: String!
		var firstWordRange: Range<String.Index>!

		input.enumerateSubstrings(in: input.startIndex..., options: .byWords, { (word, wordRange, _, stop) in
			firstWord = word
			firstWordRange = wordRange
			stop = true
		})

		return input.replacingCharacters(in: firstWordRange, with: firstWord.localizedCapitalized)
	}

	static let ceil = Filter(identifier: "ceil") { (input, _) -> String in

		guard let inputDouble = Double(input) else {
				return input
		}

		return "\(Int(Darwin.ceil(inputDouble)))"
	}

	// static let compact: Filter
	// static let concat: Filter

	static let date = Filter(identifier: "date") { (input, parameters) -> String in

		guard let formatString = parameters.first else {
			return input
		}

		var date: Date? = nil

		if input == "today" || input == "now" {
			date = Date()
		} else {
			let styles: [DateFormatter.Style] = [.none, .short, .medium, .long, .full]
			let dateFormatter = DateFormatter()

			for dateStyle in styles {
				for timeStyle in styles {
					dateFormatter.dateStyle = dateStyle
					dateFormatter.timeStyle = timeStyle

					dateFormatter.locale = Locale.current

					if let parsedDate = dateFormatter.date(from: input) {
						date = parsedDate
						break
					}

					dateFormatter.locale = Locale(identifier: "en_US")

					if let parsedDate = dateFormatter.date(from: input) {
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

		return strFormatter.string(from: date!) ?? input
	}

//	static let `default`: Filter
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
