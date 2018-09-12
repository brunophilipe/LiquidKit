//
//  Parser.swift
//  Liquid
//
//  Created by YourtionGuo on 28/06/2017.
//
//

import Foundation

/// A class for parsing an array of tokens and converts them into a collection of Node's
open class TokenParser
{
    private var tokens: [Token]
    private let context: Context
	private var filters: [Filter] = []
    
    public init(tokens: [Token], context: Context)
	{
        self.tokens = tokens
        self.context = context

		registerFilters()
    }

	open func registerFilters()
	{
		filters.append(contentsOf: [
			.abs, .append, .atLeast, .atMost, .capitalize, .ceil, .date, .default, .dividedBy, .downcase, .escape,
			.escapeOnce, .floor, .join, .leftStrip, .minus, .modulo, .newlineToBr, .plus, .prepend, .remove,
			.removeFirst, .replace, .replaceFirst, .reverse, .round, .rightStrip, .size, .slice, .sort, .sortNatural,
			.split, .strip, .stripHTML, .stripNewlines, .times, .truncate, .truncateWords, .uniq, .upcase, .urlDecode,
			.urlEncode
		])
	}
    
    /// Parse the given tokens into nodes
    public func parse() -> [String]
	{
        var nodes = [String]()
        
        while let token = nextToken()
		{
            switch token
			{
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
    
    public func nextToken() -> Token?
	{
        if tokens.count > 0
		{
            return tokens.remove(at: 0)
        }
        
        return nil
    }
    
    private func compileFilter(_ token: String) -> Token.Value
	{
		let splitToken = token.split(separator: "|")

		if splitToken.count == 1
		{
			return context.valueOrLiteral(for: token)
		}

		var filteredValue = context.valueOrLiteral(for: String(splitToken.first!))

		for filterString in splitToken[1...]
		{
			let filterComponents = String(filterString).smartSplit(separator: ":")

			guard filterComponents.count <= 2 else
			{
				NSLog("Error: bad filter syntax: \(filterString). Stopping filter processing.")
				return filteredValue
			}

			let filterIdentifier = String(filterComponents.first!).trimmingWhitespaces
			let filterParameters: [Token.Value]?

			if filterComponents.count == 1
			{
				filterParameters = []
			}
			else
			{
				filterParameters = String(filterComponents.last!).smartSplit(separator: ",").map({ context.valueOrLiteral(for: String($0)) })
			}

			guard let filter = filters.first(where: { $0.identifier == filterIdentifier }) else
			{
				NSLog("Unknown filter name: \(filterIdentifier). Stopping filter processing.")
				return filteredValue
			}

			filteredValue = filter.lambda(filteredValue, filterParameters ?? [])
		}

        return filteredValue
    }
}
