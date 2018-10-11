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

	/// Expression which defines the structure of the tag's expression.
	internal var tagExpression: [ExpressionSegment]
	{
		return []
	}

	internal var parameters: [String]
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

	/// Tags classes that should be skipped after evaluation this tag. This value is only invoked after
	/// `shouldEnter(scope:)` returns.
	internal var tagKindsToSkip: Set<Tag.Kind>?

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
	internal func parse(statement: String, using parser: TokenParser, currentScope: TokenParser.Scope) throws
	{
		var processedStatement = statement

		// Extract any parameters from the tail of the statement first. Parameters are all optional.
		for parameter in parameters
		{
			let pattern = "\(parameter)(\\s*:\\s*(\\w+))?"

			// Since NSRegularExpression doesn't support backwards search, we search using this method first.
			guard let range = processedStatement.range(of: pattern, options: [.backwards, .regularExpression]) else
			{
				// Parameter not found.
				continue
			}

			let parameterStatement = String(processedStatement[range])
			let nsParameterStatement = parameterStatement as NSString

			// Now that we found the parameter range we use NSRegularExpression to extract the capture groups.
			let regex = try! NSRegularExpression(pattern: pattern, options: [])

			if let match = regex.firstMatch(in: parameterStatement, options: [], range: nsParameterStatement.fullRange)
			{
				if match.range(at: 2).location != NSNotFound
				{
					// This parameter has a value, so we parse that value and assign it to the keyword.
					let value = nsParameterStatement.substring(with: match.range(at: 2))
					compiledExpression[parameter] = parser.compileFilter(value, context: currentScope.context)
				}
				else
				{
					// This parameter is just a keyword with no value, so we just assign true to it.
					compiledExpression[parameter] = Token.Value.bool(true)
				}

				// Remove the parameter from the remaining statement.
				processedStatement.removeSubrange(range)
			}
		}

		let scanner = Scanner(processedStatement.trimmingWhitespaces)

		// Search for the expected segments from left to right. It is up to tags to evaluate if a segment is valid.
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

				compiledExpression[name] = parser.compileFilter(scanner.scanUntilEnd(), context: currentScope.context)
			}
		}

		// Skip any left whitespace
		_ = scanner.scan(until: CharacterSet.whitespaces.inverted)

		guard scanner.isEmpty else
		{
			throw Errors.malformedStatement("Expected end of tag expression, but found \(scanner.content)")
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
		TagWhen.self, TagFor.self, TagEndFor.self, TagBreak.self, TagContinue.self
	]
}

internal extension Tag
{
	typealias Kind = Int

	class var kind: Kind
	{
		return self.keyword.hashValue
	}
}

// MARK: - Assignment

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

	override func parse(statement: String, using parser: TokenParser, currentScope: TokenParser.Scope) throws
	{
		try super.parse(statement: statement, using: parser, currentScope: currentScope)

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

	override func parse(statement: String, using parser: TokenParser, currentScope: TokenParser.Scope) throws
	{
		try super.parse(statement: statement, using: parser, currentScope: currentScope)

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

	override func parse(statement: String, using parser: TokenParser, currentScope: TokenParser.Scope) throws
	{
		try super.parse(statement: statement, using: parser, currentScope: currentScope)

		guard let assignee = compiledExpression["assignee"] as? String else
		{
			throw Errors.missingArtifacts
		}

		output = [.integer(context.decrementCounter(for: assignee))]
	}
}

class TagCapture: Tag
{
	internal override var tagExpression: [ExpressionSegment]
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
	
	override func parse(statement: String, using parser: TokenParser, currentScope: TokenParser.Scope) throws
	{
		try super.parse(statement: statement, using: parser, currentScope: currentScope)
		
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
		scope.dumpProcessedStatements()
	}
}

// MARK: - Control Flow

class TagIf: Tag
{
	internal override var tagExpression: [ExpressionSegment]
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

	override func parse(statement: String, using parser: TokenParser, currentScope: TokenParser.Scope) throws
	{
		try super.parse(statement: statement, using: parser, currentScope: currentScope)

		guard compiledExpression["conditional"] is Token.Value else
		{
			throw Errors.missingArtifacts
		}
	}

	override func didDefine(scope: TokenParser.Scope, parser: TokenParser)
	{
		super.didDefine(scope: scope, parser: parser)

		// An `if` tag should execute if its statement is considered "truthy".
		if let conditional = (compiledExpression["conditional"] as? Token.Value), conditional.isTruthy
		{
			tagKindsToSkip = [TagElsif.kind, TagElse.kind]
		}
		else
		{
			scope.outputState = .disabled
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
	override class var keyword: String
	{
		return "else"
	}

	override var definesScope: Bool
	{
		return true
	}

	override var terminatesScopesWithTags: [Tag.Type]?
	{
		return [TagIf.self, TagElsif.self, TagWhen.self]
	}

	override func didDefine(scope: TokenParser.Scope, parser: TokenParser)
	{
		super.didDefine(scope: scope, parser: parser)

		if scope.parentScope?.tag is TagCase
		{
			scope.parentScope?.outputState = .enabled
		}
	}
}

class TagElsif: TagIf
{
	override class var keyword: String
	{
		return "elsif"
	}

	override var terminatesScopesWithTags: [Tag.Type]?
	{
		return [TagIf.self, TagElsif.self]
	}
}

class TagUnless: TagIf
{
	override class var keyword: String
	{
		return "unless"
	}

	override func didDefine(scope: TokenParser.Scope, parser: TokenParser)
	{
		super.didDefine(scope: scope, parser: parser)

		// An `unless` tag should execute if its statement is considered "falsy".
		if let conditional = (compiledExpression["conditional"] as? Token.Value), conditional.isTruthy
		{
			scope.outputState = .disabled
		}
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
	internal override var tagExpression: [ExpressionSegment]
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

	override func parse(statement: String, using parser: TokenParser, currentScope: TokenParser.Scope) throws
	{
		try super.parse(statement: statement, using: parser, currentScope: currentScope)

		guard compiledExpression["conditional"] is Token.Value else
		{
			throw Errors.missingArtifacts
		}
	}

	override func didDefine(scope: TokenParser.Scope, parser: TokenParser)
	{
		// Prevent rogue text between the `case` tag and the first `when` tag from being output.
		scope.outputState = .disabled
	}
}

class TagWhen: Tag
{
	internal override var tagExpression: [ExpressionSegment]
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

	override func parse(statement: String, using parser: TokenParser, currentScope: TokenParser.Scope) throws
	{
		try super.parse(statement: statement, using: parser, currentScope: currentScope)

		guard compiledExpression["comparator"] is Token.Value else
		{
			throw Errors.missingArtifacts
		}
	}

	override func didDefine(scope: TokenParser.Scope, parser: TokenParser)
	{
		super.didDefine(scope: scope, parser: parser)

		guard
			let tagCase = scope.parentScope?.tag as? TagCase,
			let comparator = compiledExpression["comparator"] as? Token.Value,
			let conditional = tagCase.compiledExpression["conditional"] as? Token.Value
		else
		{
			scope.outputState = .disabled
			return
		}

		let isMatch = comparator == conditional

		if isMatch
		{
			tagKindsToSkip = [TagWhen.kind, TagElse.kind]
		}

		scope.outputState = isMatch ? .enabled : .disabled
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

// MARK: - Iteration

protocol IterationTag
{
	var supplementalContext: Context? { get }

	var hasSupplementalContext: Bool { get }
}

class TagFor: Tag, IterationTag
{
	private var iterator: IndexingIterator<([Token.Value])>!

	private(set) var hasSupplementalContext: Bool = true

	var supplementalContext: Context?
	{
		guard let item = iterator.next(), let iteree = compiledExpression["iteree"] as? String else
		{
			hasSupplementalContext = false
			return nil
		}

		return context.makeSupplement(with: [iteree: item])
	}

	override class var keyword: String
	{
		return "for"
	}

	internal override var tagExpression: [ExpressionSegment]
	{
		// example: {% for IDENTIFIER in IDENTIFIER %}
		return [.identifier("iteree"), .literal("in"), .variable("iterand")]
	}

	override var parameters: [String]
	{
		return ["limit", "offset", "reversed"]
	}

	override var definesScope: Bool
	{
		return true
	}

	override func parse(statement: String, using parser: TokenParser, currentScope: TokenParser.Scope) throws
	{
		try super.parse(statement: statement, using: parser, currentScope: currentScope)

		guard
			compiledExpression["iteree"] is String,
			let iterandValue = compiledExpression["iterand"] as? Token.Value
		else
		{
			throw Errors.missingArtifacts
		}

		var values: [Token.Value]

		switch iterandValue
		{
		case .array(let array):
			values = array

		case .range(let range):
			values = range.lazy.map({ Token.Value.integer($0) })

		default:
			throw Errors.malformedStatement("Expected array or range parameter for for statement, found \(type(of: iterandValue))")
		}

		if let offset = (compiledExpression["offset"] as? Token.Value)?.integerValue
		{
			values.removeSubrange(..<offset)
		}

		if let limit = (compiledExpression["limit"] as? Token.Value)?.integerValue
		{
			values.removeSubrange(limit...)
		}

		if compiledExpression["reversed"] as? Token.Value == .bool(true)
		{
			values.reverse()
		}

		self.iterator = values.makeIterator()
	}
}

class TagEndFor: Tag
{
	override class var keyword: String
	{
		return "endfor"
	}

	override var terminatesScopesWithTags: [Tag.Type]?
	{
		return [TagFor.self]
	}
}

class TagBreak: Tag
{
	override class var keyword: String
	{
		return "break"
	}

	override func parse(statement: String, using parser: TokenParser, currentScope: TokenParser.Scope) throws
	{
		try super.parse(statement: statement, using: parser, currentScope: currentScope)

		if currentScope.outputState == .enabled, let forScope = currentScope.scopeDefined(by: [TagFor.kind])
		{
			// If the current scope produces output, finds the nearest iterator and stops its output.
			forScope.outputState = .disabled
		}
	}
}

class TagContinue: Tag
{
	override class var keyword: String
	{
		return "continue"
	}

	override func parse(statement: String, using parser: TokenParser, currentScope: TokenParser.Scope) throws
	{
		try super.parse(statement: statement, using: parser, currentScope: currentScope)

		if currentScope.outputState == .enabled, let forScope = currentScope.scopeDefined(by: [TagFor.kind])
		{
			forScope.outputState = .halted
		}
	}
}
