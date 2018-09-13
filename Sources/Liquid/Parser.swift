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
	private var tags: [String: [Tag.Type]] = [:]
    
    public init(tokens: [Token], context: Context)
	{
        self.tokens = tokens
        self.context = context

		registerFilters()
		registerTags()
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

	open func registerTags()
	{
		Tag.builtInTags.forEach(register)
	}
    
    /// Parse the given tokens into nodes
    public func parse() -> [String]
	{
        var nodes = [String]()
		var skipUntil: [Tag.Type]? = nil

        while let token = nextToken()
		{
            switch token
			{
            case .text where skipUntil == nil:
                nodes.append(token.contents)

            case .variable where skipUntil == nil:
                nodes.append(compileFilter(token.contents).stringValue)

			case .tag:
				guard let tag = compileTag(token.contents) else
				{
					// Unknown tag keyword or invalid statement
					break
				}

				if let wantedTags = skipUntil, !wantedTags.contains(where: { type(of: tag) == $0 })
				{
					// We were told to ignore this tag type
					break
				}

				if let output = tag.output
				{
					// This tag produced an output (incremend/decrement, for example). Append it to the nodes.
					nodes.append(contentsOf: output.map({ $0.stringValue }))
				}

				if let flowControlTag = tag as? FlowControlTag, let skipUntilTags = flowControlTag.skipUntil
				{
					// This is a flow control tag, and it told us to skip until the given tag type.
					skipUntil = skipUntilTags
				}
				else
				{
					skipUntil = nil
				}

			default:
				break
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

	public func register(filter: Filter)
	{
		filters.append(filter)
	}

	public func register(tag: Tag.Type)
	{
		if tags[tag.keyword] == nil
		{
			tags[tag.keyword] = [tag]
		}
		else
		{
			tags[tag.keyword]?.append(tag)
		}
	}
    
    internal func compileFilter(_ token: String) -> Token.Value
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

	private func compileTag(_ contents: String) -> Tag?
	{
		let contentScanner = Scanner(contents.trimmingWhitespaces)
		let keyword = contentScanner.scan(until: .whitespaces)

		guard keyword.count > 0 else
		{
			NSLog("Malformed tag: “\(contents)”")
			return nil
		}

		guard let tags = self.tags[String(keyword)], tags.count > 0 else
		{
			NSLog("Unknown tag keyword: “\(keyword)”")
			return nil
		}

		let statement = contentScanner.content

		for tag in tags
		{
			let tagInstance = tag.init(context: context)

			do
			{
				try tagInstance.parse(statement: statement, using: self)

				return tagInstance
			}
			catch
			{
				NSLog("Error parsing tag: \(error.localizedDescription)")
			}
		}

		return nil
	}
	
}
