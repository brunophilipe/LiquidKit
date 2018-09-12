//
//  Tag.swift
//  Liquid
//
//  Created by Bruno Philipe on 11/09/2018.
//

import Foundation

/// A class representing a filter
class Tag
{
	internal var tagExpression: [ExpressionSegment]
	{
		return []
	}

	internal var compiledExpression: [String: Any] = [:]

	var context: Context

	init(context: Context)
	{
		self.context = context
	}

	/// Given a string statement, attempts to compile the receiver tag.
	func compile(from statement: String) throws
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

			case .value(let name):
				guard !scanner.isEmpty else
				{
					throw Errors.malformedStatement("Expected identifier or literal, found nothing.")
				}

				var foundWord = scanner.scan(until: .whitespaces, skipEarlyMatches: true)

				if foundWord.hasPrefix("\"")
				{
					// will need to find matching closing double quote

					while !scanner.isEmpty
					{
						let nextWord = scanner.scan(until: "\"")
						foundWord.append(nextWord)

						if !nextWord.hasSuffix("\"")
						{
							// We found the closing double quote
							foundWord.append("\"")
							break
						}
					}
				}

				compiledExpression[name] = context.valueOrLiteral(for: foundWord)
			}
		}
	}

	enum ExpressionSegment
	{
		/// A literal string. This segment must be matched exactly.
		case literal(String)

		/// An identifier name. This segment will match any valid unquoted identifier string (alphanumeric).
		case identifier(String)

		/// A valid token value. This segment will match any token value, such as a quoted string, a number, or a
		/// variable defined in the receiver's context. If none of these are matched, is assigned `Token.Value.nil`.
		case value(String)
	}

	enum Errors: Error
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

class TagAssign: Tag
{
	internal override var tagExpression: [ExpressionSegment]
	{
		// example: {% assign IDENTIFIER = "value" %}
		return [.literal("assign"), .identifier("assignee"), .literal("="), .value("value")]
	}

	override func compile(from statement: String) throws
	{
		try super.compile(from: statement)

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
