//
//  Parser.swift
//  Liquid
//
//  Created by YourtionGuo on 28/06/2017.
//
//

import Foundation

/// A class for parsing an array of tokens and converts them into a collection of Node's
open class TokenParser {
    
    private var tokens: [Token]
    private let context: Context
	private var filters: [Filter] = []
    
    public init(tokens: [Token], context: Context) {
        self.tokens = tokens
        self.context = context

		registerFilters()
    }

	open func registerFilters() {
		filters.append(.abs)
		filters.append(.append)
		filters.append(.atLeast)
		filters.append(.atMost)
		filters.append(.capitalize)
		filters.append(.ceil)
		filters.append(.date)
		filters.append(.default)
		filters.append(.dividedBy)
		filters.append(.downcase)
		filters.append(.escape)
		filters.append(.escapeOnce)

		filters.append(.join)

		filters.append(.split)
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
                nodes.append(compileFilter(token.contents).stringValue)

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
    
    private func compileFilter(_ token: String) -> Filter.Value {

		func valueOrLiteral(for token: String) -> Filter.Value
		{
			let trimmedToken = token.trimmingWhitespaces

			if trimmedToken.hasPrefix("\""), trimmedToken.hasSuffix("\"")
			{
				// This is a literal string. Strip its quotations.
				return .string(trimmedToken.trim(character: "\""))
			}
			else if let integer = Int(trimmedToken)
			{
				// This is an integer literal (the integer constructor fails if a decimal point is found).
				return .integer(integer)
			}
			else if let number = Decimal(string: trimmedToken)
			{
				// This is a decimal literal.
				return .decimal(number)
			}
			else
			{
				// This is a variable name. Return its value, or an empty string.
				return self.context.getValue(for: trimmedToken) ?? .nil
			}
		}

		let splitToken = token.split(separator: "|", maxSplits: 2)

		if splitToken.count == 1 {
			return valueOrLiteral(for: token)
		}

		var filteredValue = valueOrLiteral(for: String(splitToken.first!))

		for filterString in splitToken[1...] {

			let filterComponents = String(filterString).smartSplit(separator: ":")
			guard filterComponents.count <= 2 else {
				NSLog("Error: bad filter syntax: \(filterString). Stopping filter processing.")
				return filteredValue
			}

			let filterIdentifier = String(filterComponents.first!).trimmingWhitespaces
			let filterParameters: [Filter.Value]?

			if filterComponents.count == 1 {
				filterParameters = []
			} else {
				filterParameters = String(filterComponents.last!).smartSplit(separator: ",").map({ valueOrLiteral(for: String($0)) })
			}

			guard let filter = filters.first(where: { $0.identifier == filterIdentifier }) else {
				NSLog("Unknown filter name: \(filterIdentifier). Stopping filter processing.")
				return filteredValue
			}

			filteredValue = filter.lambda(filteredValue, filterParameters ?? [])
		}

        return filteredValue
    }
}
