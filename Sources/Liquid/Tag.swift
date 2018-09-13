//
//  Tag.swift
//  Liquid
//
//  Created by Bruno Philipe on 11/09/2018.
//

import Foundation

/// A class representing a filter
public class Tag
{
	public class var keyword: String
	{
		return ""
	}

	internal var tagExpression: [ExpressionSegment]
	{
		return []
	}

	internal var compiledExpression: [String: Any] = [:]
	internal var context: Context

	public var definesScope: Bool
	{
		return false
	}

	public var terminatesScopesWithTags: [Tag.Type]?
	{
		return nil
	}

	public var shouldEnterScope: Bool
	{
		return false
	}

	/// If compiling this tag produces an output, this value will be stored here.
	public internal(set) var output: [Token.Value]? = nil

	public required init(context: Context)
	{
		self.context = context
	}

	/// Given a string statement, attempts to compile the receiver tag.
	open func parse(statement: String, using parser: TokenParser) throws
	{
		let scanner = Scanner(statement.trimmingWhitespaces)

		for segment in tagExpression
		{
			switch segment
			{
			case .literal(let expectedWord):
				guard !scanner.isEmpty else
				{
					throw Errors.malformedStatement("Expected literal “\(expectedWord)”, found nothing.")
				}

				let foundWord = scanner.scan(until: .whitespaces, skipEarlyMatches: true)

				guard foundWord == expectedWord else
				{
					throw Errors.malformedStatement("Unexpected statement “\(foundWord)”, expected “\(expectedWord)”.")
				}

				compiledExpression[expectedWord] = foundWord

			case .identifier(let name):
				guard !scanner.isEmpty else
				{
					throw Errors.malformedStatement("Expected identifier, found nothing.")
				}

				let foundWord = scanner.scan(until: .whitespaces, skipEarlyMatches: true)
				compiledExpression[name] = foundWord

			case .variable(let name):
				guard !scanner.isEmpty else
				{
					throw Errors.malformedStatement("Expected identifier or literal, found nothing.")
				}

				compiledExpression[name] = parser.compileFilter(scanner.content)
			}
		}
	}

	public enum ExpressionSegment
	{
		/// A literal string. This segment must be matched exactly.
		case literal(String)

		/// An identifier name. This segment will match any valid unquoted identifier string (alphanumeric).
		case identifier(String)

		/// A valid token value. This segment will match any token value, such as a quoted string, a number, or a
		/// variable defined in the receiver's context, and any filters applied to it afterwards. If none of these are
		/// matched, is assigned `Token.Value.nil`.
		case variable(String)
	}

	public enum Errors: Error
	{
		case malformedStatement(String)
		case missingArtifacts

		var localizedDescription: String
		{
			switch self
			{
			case .malformedStatement(let description): return description
			case .missingArtifacts: return "Compiler error: Compilaton reported success but required artifacts are missing."
			}
		}
	}
}

extension Tag
{
	static let builtInTags: [Tag.Type] = [
		TagAssign.self, TagIncrement.self, TagDecrement.self, TagIf.self, TagEndIf.self
	]
}

class TagAssign: Tag
{
	internal override var tagExpression: [ExpressionSegment]
	{
		// example: {% assign IDENTIFIER = "value" %}
		return [.identifier("assignee"), .literal("="), .variable("value")]
	}

	override class var keyword: String
	{
		return "assign"
	}

	override func parse(statement: String, using parser: TokenParser) throws
	{
		try super.parse(statement: statement, using: parser)

		guard
			let assignee = compiledExpression["assignee"] as? String,
			let value = compiledExpression["value"] as? Token.Value
		else
		{
			throw Errors.missingArtifacts
		}

		context.set(value: value, for: assignee)
	}
}

class TagIncrement: Tag
{
	internal override var tagExpression: [ExpressionSegment]
	{
		// example: {% increment IDENTIFIER %}
		return [.identifier("assignee")]
	}

	override class var keyword: String
	{
		return "increment"
	}

	override func parse(statement: String, using parser: TokenParser) throws
	{
		try super.parse(statement: statement, using: parser)

		guard let assignee = compiledExpression["assignee"] as? String else
		{
			throw Errors.missingArtifacts
		}

		output = [.integer(context.incrementCounter(for: assignee))]
	}
}

class TagDecrement: Tag
{
	internal override var tagExpression: [ExpressionSegment]
	{
		// example: {% increment IDENTIFIER %}
		return [.identifier("assignee")]
	}

	override class var keyword: String
	{
		return "decrement"
	}

	override func parse(statement: String, using parser: TokenParser) throws
	{
		try super.parse(statement: statement, using: parser)

		guard let assignee = compiledExpression["assignee"] as? String else
		{
			throw Errors.missingArtifacts
		}

		output = [.integer(context.decrementCounter(for: assignee))]
	}
}
