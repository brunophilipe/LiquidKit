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
	/// Keyword used to identify the receiver tag.
	public class var keyword: String
	{
		return ""
	}

	/// Expression which defines the structure of the accepted parameters for the receiver tag.
	internal var tagParametersExpression: [ExpressionSegment]
	{
		return []
	}

	/// Storage for the compiled statement expression, which is populated after a successful compilation.
	internal var compiledExpression: [String: Any] = [:]

	/// The context where variables, counters, and other properties are stored.
	internal let context: Context

	/// If true, will create a scope for this tag upon compiling it. One or more closing tgas will need to be defined
	/// to close that scope. Those tags will need the name of this class in its `terminatesScopesWithTags` property.
	internal var definesScope: Bool
	{
		return false
	}

	/// If defined, lists which scopes this this tag will close, based on their opener tags.
	internal var terminatesScopesWithTags: [Tag.Type]?
	{
		return nil
	}

	/// Whether the parent scope of the scope terminated by this tag should also be terminated.
	internal var terminatesParentScope: Bool
	{
		return false
	}

	/// Whether the statement provided to this tag causes its scope to be executed.
	///
	/// *Notice:* This value is only evaluated if `definesScope` returns `true`.
	internal func shouldEnter(scope: TokenParser.Scope) -> Bool
	{
		return false
	}

	/// If this tag terminates a scope during preprocessing, the parser will invoke this method with the new scope.
	internal func didTerminate(scope: TokenParser.Scope, parser: TokenParser)
	{
	}

	/// If this tag defines a scope during preprocessing, the parser will invoke this method with the new scope.
	internal func didDefine(scope: TokenParser.Scope, parser: TokenParser)
	{
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

		for segment in tagParametersExpression
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
		TagAssign.self, TagIncrement.self, TagDecrement.self, TagIf.self, TagEndIf.self, TagElse.self, TagElsif.self,
		TagCapture.self, TagEndCapture.self, TagUnless.self, TagEndUnless.self, TagCase.self, TagEndCase.self,
		TagWhen.self
	]
}

// MARK: - Assignment

class TagAssign: Tag
{
	internal override var tagParametersExpression: [ExpressionSegment]
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
	internal override var tagParametersExpression: [ExpressionSegment]
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
	internal override var tagParametersExpression: [ExpressionSegment]
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

class TagCapture: Tag
{
	internal override var tagParametersExpression: [ExpressionSegment]
	{
		// example: {% capture IDENTIFIER %}
		return [.identifier("assignee")]
	}
	
	override class var keyword: String
	{
		return "capture"
	}
	
	override var definesScope: Bool
	{
		return true
	}
	
	override func shouldEnter(scope: TokenParser.Scope) -> Bool
	{
		return true
	}
	
	override func parse(statement: String, using parser: TokenParser) throws
	{
		try super.parse(statement: statement, using: parser)
		
		guard compiledExpression["assignee"] is String else
		{
			throw Errors.missingArtifacts
		}
	}
}

class TagEndCapture: Tag
{
	override class var keyword: String
	{
		return "endcapture"
	}
	
	override var terminatesScopesWithTags: [Tag.Type]?
	{
		return [TagCapture.self]
	}
	
	override func didTerminate(scope: TokenParser.Scope, parser: TokenParser)
	{
		if let assigneeName = scope.tag?.compiledExpression["assignee"] as? String,
			let compiledCapturedStatements = scope.compile(using: parser)
		{
			context.set(value: .string(compiledCapturedStatements.joined()), for: assigneeName)
		}

		// Prevent the nodes of the scope from being written to the output when the final compilation happens.
		scope.producesOutput = false
	}
}

// MARK: - Control Flow

class TagIf: Tag
{
	internal override var tagParametersExpression: [ExpressionSegment]
	{
		// example: {% if IDENTIFIER %}
		return [.variable("conditional")]
	}

	override var definesScope: Bool
	{
		return true
	}

	override class var keyword: String
	{
		return "if"
	}

	override func shouldEnter(scope: TokenParser.Scope) -> Bool
	{
		// An `if` tag should execute if its statement is considered "truthy".
		if let conditional = (compiledExpression["conditional"] as? Token.Value), conditional.isTruthy
		{
			return true
		}

		return false
	}

	override func parse(statement: String, using parser: TokenParser) throws
	{
		try super.parse(statement: statement, using: parser)

		guard compiledExpression["conditional"] is Token.Value else
		{
			throw Errors.missingArtifacts
		}
	}
}

class TagEndIf: Tag
{
	override class var keyword: String
	{
		return "endif"
	}

	override var terminatesScopesWithTags: [Tag.Type]?
	{
		return [TagIf.self, TagElse.self, TagElsif.self]
	}
}

class TagElse: Tag
{
	private var terminatedScopeTag: Tag? = nil

	override class var keyword: String
	{
		return "else"
	}

	override var definesScope: Bool
	{
		return true
	}

	override func shouldEnter(scope: TokenParser.Scope) -> Bool
	{
		if let tagIf = terminatedScopeTag as? TagIf
		{
			return !tagIf.shouldEnter(scope: scope)
		}
		else if let tagCase = scope.parentScope?.tag as? TagCase
		{
			return !tagCase.didMatchWhenTag
		}
		else
		{
			return false
		}
	}

	override func didTerminate(scope: TokenParser.Scope, parser: TokenParser)
	{
		terminatedScopeTag = scope.tag
	}

	override var terminatesScopesWithTags: [Tag.Type]?
	{
		return [TagIf.self, TagElsif.self, TagWhen.self]
	}
}

class TagElsif: TagIf
{
	private var terminatedScopeTag: Tag? = nil

	override class var keyword: String
	{
		return "elsif"
	}

	override var terminatesScopesWithTags: [Tag.Type]?
	{
		return [TagIf.self, TagElsif.self]
	}

	override func shouldEnter(scope: TokenParser.Scope) -> Bool
	{
		// An `elsif` tag should be executed if an immediatelly prior `if` tag is not executed, and its statement
		// evaluates to `true`
		if let ifTag = terminatedScopeTag as? TagIf
		{
			return !ifTag.shouldEnter(scope: scope) && super.shouldEnter(scope: scope)
		}
		else
		{
			return false
		}
	}

	override func didTerminate(scope: TokenParser.Scope, parser: TokenParser)
	{
		terminatedScopeTag = scope.tag
	}
}

class TagUnless: TagIf
{
	override class var keyword: String
	{
		return "unless"
	}

	override func shouldEnter(scope: TokenParser.Scope) -> Bool
	{
		// An `unless` tag should execute if its statement is considered "falsy".
		if let conditional = (compiledExpression["conditional"] as? Token.Value), conditional.isFalsy
		{
			return true
		}

		return false
	}
}

class TagEndUnless: Tag
{
	override class var keyword: String
	{
		return "endunless"
	}

	override var terminatesScopesWithTags: [Tag.Type]?
	{
		return [TagUnless.self]
	}
}

class TagCase: Tag
{
	internal var didMatchWhenTag = false

	internal override var tagParametersExpression: [ExpressionSegment]
	{
		return [.variable("conditional")]
	}

	override class var keyword: String
	{
		return "case"
	}

	override var definesScope: Bool
	{
		return true
	}

	override func shouldEnter(scope: TokenParser.Scope) -> Bool
	{
		return true
	}

	override func parse(statement: String, using parser: TokenParser) throws
	{
		try super.parse(statement: statement, using: parser)

		guard compiledExpression["conditional"] is Token.Value else
		{
			throw Errors.missingArtifacts
		}
	}

	override func didDefine(scope: TokenParser.Scope, parser: TokenParser)
	{
		scope.producesOutput = false
	}
}

class TagWhen: Tag
{
	internal override var tagParametersExpression: [ExpressionSegment]
	{
		return [.variable("comparator")]
	}

	override class var keyword: String
	{
		return "when"
	}

	override var definesScope: Bool
	{
		return true
	}

	override func shouldEnter(scope: TokenParser.Scope) -> Bool
	{
		guard
			let tagCase = scope.parentScope?.tag as? TagCase,
			let comparator = compiledExpression["comparator"] as? Token.Value,
			let conditional = tagCase.compiledExpression["conditional"] as? Token.Value
		else
		{
			return false
		}

		let isMatch = comparator == conditional

		if isMatch, !tagCase.didMatchWhenTag
		{
			tagCase.didMatchWhenTag = true
			return true
		}
		else
		{
			return false
		}
	}

	override func parse(statement: String, using parser: TokenParser) throws
	{
		try super.parse(statement: statement, using: parser)

		guard compiledExpression["comparator"] is Token.Value else
		{
			throw Errors.missingArtifacts
		}
	}

	override var terminatesScopesWithTags: [Tag.Type]?
	{
		return [TagWhen.self]
	}
}

class TagEndCase: Tag
{
	private var shouldTerminateParentScope = false

	override class var keyword: String
	{
		return "endcase"
	}

	override var terminatesScopesWithTags: [Tag.Type]?
	{
		return [TagCase.self, TagElse.self]
	}

	override func didTerminate(scope: TokenParser.Scope, parser: TokenParser)
	{
		shouldTerminateParentScope = scope.tag is TagElse && scope.parentScope?.tag is TagCase
	}

	override var terminatesParentScope: Bool
	{
		return shouldTerminateParentScope
	}
}
