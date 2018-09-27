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
	private var operators: [Operator] = []
	private var tags: [String: [Tag.Type]] = [:]
	private var parseErrors: [Error] = []

	public init(tokens: [Token], context: Context)
	{
		self.tokens = tokens
		self.context = context

		registerFilters()
		registerTags()
		registerOperators()
	}

	open func registerFilters()
	{
		Filter.builtInFilters.forEach(register)
	}

	open func registerTags()
	{
		Tag.builtInTags.forEach(register)
	}

	open func registerOperators()
	{
		Operator.builtInOperators.forEach(register)
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

	public func register(operator: Operator)
	{
		operators.append(`operator`)
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
	private func preprocessTokens() -> Scope
	{
		let rootScope = Scope()
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
					tag.didTerminateScope(currentScope, parser: self)

					if tag.terminatesParentScope, let grampaScope = currentScope.parentScope?.parentScope
					{
						currentScope = grampaScope
					}
					else if let parentScope = currentScope.parentScope
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
					tag.didDefineScope(currentScope, parser: self)
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
			return compileOperators(for: statement)
		}

		var filteredValue = compileOperators(for: String(splitStatement.first!))

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
				filterParameters = String(filterComponents.last!).smartSplit(separator: ",").map({ context.valueOrLiteral(for: String($0)) ?? .nil })
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

	internal func compileOperators(for statement: String) -> Token.Value
	{
		if statement.count == 0
		{
			return .nil
		}

		let statementNodes = statement.smartSplit(separator: " ").filter({ $0.count > 0 })

		if statementNodes.count <= 1
		{
			return context.valueOrLiteral(for: statement) ?? .nil
		}

		var iterator = statementNodes.reversed().makeIterator()
		var lastParsedValue: Token.Value? = nil

		// Liquid parses boolean operators right right to left, and doesn't support parenthesis.
		while let node = iterator.next()
		{
			var secondNode = node

			// Can't perform a logical operation if a previous value wasn't parsed yet.
			if ["or", "and"].contains(node)
			{
				if lastParsedValue == nil
				{
					parseErrors.append(ParseErrors.malformedExpression("Malformed expression: Expected value but found logical operator “\(node)”."))
					return .nil
				}
				else if let nextNode = iterator.next()
				{
					secondNode = nextNode
				}
				else
				{
					parseErrors.append(ParseErrors.malformedExpression("Malformed expression: Expected value but found nothing."))
					return .nil
				}
			}

			guard let secondValue = context.valueOrLiteral(for: secondNode) else
			{
				parseErrors.append(ParseErrors.malformedExpression("Malformed expression: Unknown variable “\(secondNode)”."))
				return .nil
			}

			guard let operatorKeyword = iterator.next() else
			{
				parseErrors.append(ParseErrors.malformedExpression("Malformed expression: Expected operator but found nothing."))
				return .nil
			}

			guard let operatorInstance = operators.first(where: { $0.identifier == operatorKeyword }) else
			{
				parseErrors.append(ParseErrors.malformedExpression("Malformed expression: Unknown operator “\(operatorKeyword)”."))
				return .nil
			}

			guard let firstNode = iterator.next() else
			{
				parseErrors.append(ParseErrors.malformedExpression("Malformed expression: Expected value before operator “\(operatorKeyword)” but found nothing."))
				return .nil
			}

			guard let firstValue = context.valueOrLiteral(for: firstNode) else
			{
				parseErrors.append(ParseErrors.malformedExpression("Malformed expression: Unknown variable “\(node)”."))
				return .nil
			}

			if let lastValue = lastParsedValue
			{
				let currentValue = operatorInstance.lambda(firstValue, secondValue)
				switch node
				{
				case "and":
					lastParsedValue = .bool(lastValue.isTruthy && currentValue.isTruthy)

				case "or":
					lastParsedValue = .bool(lastValue.isTruthy || currentValue.isTruthy)

				default:
					parseErrors.append(ParseErrors.malformedExpression("Malformed expression: Unknown logical operator “\(node)”."))
					return .nil
				}
			}
			else
			{
				lastParsedValue = operatorInstance.lambda(firstValue, secondValue)
			}
		}

		return lastParsedValue ?? .nil
	}

	/// Defines a level of scope during parsing. Each time a scope-defining tag is found (such as `if`, `else`, etc…),
	/// a new scope is defined. Closing tags (such as `endif`, `elsif`, etc) terminate scopes.
	internal class Scope
	{
		/// The tag that defined this scope level. Is only `nil` on the root scope level.
		let tag: Tag?

		/// The parent scope level, that contains the receiver scope. Is only `nil` on the root scope level.
		let parentScope: Scope?
		
		/// Whether the processed statements should be compiled and written to the output. Default is `true`.
		var producesOutput = true

		/// The statements inside the receiver scope.
		private(set) var processedStatements: [ProcessedStatement] = []

		init(tag: Tag? = nil, parent: Scope? = nil)
		{
			self.tag = tag
			self.parentScope = parent

			parent?.processedStatements.append(.scope(self))
		}

		/// Append a raw string to the processed statements of the receiver scope level.
		func append(rawOutput: String)
		{
			processedStatements.append(.rawOutput(rawOutput))
		}

		/// Append a string that should be parsed as a filter to the processed statements of the receiver scope level.
		func append(filteredOutput: String)
		{
			processedStatements.append(.filteredOutput(filteredOutput))
		}

		/// Append a tag to the processed statements of the receiver scope level, thus defining a child scope level.
		func appendScope(for tag: Tag) -> Scope
		{
			return Scope(tag: tag, parent: self)
		}

		enum ProcessedStatement
		{
			case rawOutput(String)
			case filteredOutput(String)
			case scope(Scope)
		}
	}

	public enum ParseErrors: Error
	{
		case malformedExpression(String)

		public var localizedDescription: String
		{
			switch self
			{
			case .malformedExpression(let description): return description
			}
		}
	}
}

internal extension TokenParser.Scope
{
	/// This method will compile the nodes of the receiver scope, depending on its opener tag and the contents of is
	/// nodes and child scopes.
	func compile(using parser: TokenParser) -> [String]?
	{
		var nodes = [String]()

		if let tag = self.tag, tag.definesScope && !tag.shouldEnterScope(self)
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
			case .rawOutput(let output) where producesOutput:
				nodes.append(output)

			case .filteredOutput(let filterStatement) where producesOutput:
				nodes.append(parser.compileFilter(filterStatement).stringValue)

			case .scope(let childScope):
				if let childNodes = childScope.compile(using: parser)
				{
					nodes.append(contentsOf: childNodes)
				}
				
			default:
				break
			}
		}

		return nodes
	}
}
