//
//  FlowControlTag.swift
//  Liquid
//
//  Created by Bruno Philipe on 11/09/2018.
//

import Foundation

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

	override var shouldEnterScope: Bool
	{
		if case .some(.bool(true)) = (compiledExpression["conditional"] as? Token.Value)
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
		return [TagIf.self, TagElse.self]
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

	override var shouldEnterScope: Bool
	{
		// An `else` tag should be executed if an immediatelly prior `if` tag is not executed.
		if let ifTag = terminatedScopeTag as? TagIf
		{
			return !ifTag.shouldEnterScope
		}
		else
		{
			return false
		}
	}

	override var terminatesScopesWithTags: [Tag.Type]?
	{
		return [TagIf.self]
	}
}
