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
		return preprocessTokens().compile(using: self) ?? []
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

	/// This method will traverse the provided tokens (which is a linear structure) and create a scoped (nested) data
	/// structure of the code, so that it can be compiled later.
	private func preprocessTokens() -> ScopeLevel
	{
		let rootScope = ScopeLevel()
		var currentScope = rootScope

		while let token = nextToken()
		{
			switch token
			{
			case .text(let contents):
				currentScope.append(rawOutput: contents)

			case .variable(let contents):
				currentScope.append(filteredOutput: contents)

			case .tag(let contents):
				guard let tag = compileTag(contents) else
				{
					// Unknown tag keyword or invalid statement
					break
				}

				// If this tag closes the opener tag, then leave the current scope.
				if let openerTag = currentScope.tag, let terminatedTags = tag.terminatesScopesWithTags,
					terminatedTags.contains(where: { type(of: openerTag) == $0 })
				{
					// Inform this tag instance that it has closed a tag.
					tag.terminatedScopeTag = currentScope.tag

					if let parentScope = currentScope.parentScopeLevel
					{
						currentScope = parentScope
					}
					else
					{
						NSLog("terminating scope tag scope has no parent scope!!!")
					}
				}

				// If this tag produces output, append that to the current scope's nodes.
				if let output = tag.output
				{
					output.map({ $0.stringValue }).forEach(currentScope.append(rawOutput:))
				}

				// If this tag defines a scope, create it and make it ther current scope.
				if tag.definesScope
				{
					currentScope = currentScope.appendScope(for: tag)
				}
			}
		}

		if currentScope !== rootScope
		{
			NSLog("Unbalanced scopes!!")
		}

		return rootScope
	}

	internal func compileFilter(_ statement: String) -> Token.Value
	{
		let splitStatement = statement.split(separator: "|")

		if splitStatement.count == 1
		{
			return context.valueOrLiteral(for: statement)
		}

		var filteredValue = context.valueOrLiteral(for: String(splitStatement.first!))

		for filterString in splitStatement[1...]
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

	private func compileTag(_ statement: String) -> Tag?
	{
		let statementScanner = Scanner(statement.trimmingWhitespaces)
		let keyword = statementScanner.scan(until: .whitespaces)

		guard keyword.count > 0 else
		{
			NSLog("Malformed tag: “\(statement)”")
			return nil
		}

		guard let tags = self.tags[String(keyword)], tags.count > 0 else
		{
			NSLog("Unknown tag keyword: “\(keyword)”")
			return nil
		}

		let statement = statementScanner.content

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

	/// Defines a level of scope during parsing. Each time a scope-defining tag is found (such as `if`, `else`, etc…),
	/// a new scope is defined. Closing tags (such as `endif`, `elsif`, etc) terminate scopes.
	fileprivate class ScopeLevel
	{
		let tag: Tag?

		let parentScopeLevel: ScopeLevel?

		var processedStatements: [ProcessedStatement] = []

		init(tag: Tag? = nil, parent: ScopeLevel? = nil)
		{
			self.tag = tag
			self.parentScopeLevel = parent

			parent?.processedStatements.append(.scope(self))
		}

		func append(rawOutput: String)
		{
			processedStatements.append(.rawOutput(rawOutput))
		}

		func append(filteredOutput: String)
		{
			processedStatements.append(.filteredOutput(filteredOutput))
		}

		func appendScope(for tag: Tag) -> ScopeLevel
		{
			return ScopeLevel(tag: tag, parent: self)
		}

		enum ProcessedStatement
		{
			case rawOutput(String)
			case filteredOutput(String)
			case scope(ScopeLevel)
		}
	}
}

private extension TokenParser.ScopeLevel
{
	/// This method will compile the nodes of the receiver scope, depending on its opener tag and the contents of is
	/// nodes and child scopes.
	func compile(using parser: TokenParser) -> [String]?
	{
		var nodes = [String]()

		if let tag = self.tag, tag.definesScope && !tag.shouldEnterScope
		{
			return tag.output?.map { $0.stringValue }
		}
		else if let outputNodes = tag?.output?.map({ $0.stringValue })
		{
			nodes.append(contentsOf: outputNodes)
		}

		for statement in processedStatements
		{
			switch statement
			{
			case .rawOutput(let output):
				nodes.append(output)

			case .filteredOutput(let filterStatement):
				nodes.append(parser.compileFilter(filterStatement).stringValue)

			case .scope(let childScope):
				if let childNodes = childScope.compile(using: parser)
				{
					nodes.append(contentsOf: childNodes)
				}
			}
		}

		return nodes
	}
}
