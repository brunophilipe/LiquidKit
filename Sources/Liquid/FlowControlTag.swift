//
//  FlowControlTag.swift
//  Liquid
//
//  Created by Bruno Philipe on 11/09/2018.
//

import Foundation

class FlowControlTag: Tag
{
	internal(set) var skipUntil: [Tag.Type]? = nil
}

class TagIf: FlowControlTag
{
	internal override var tagExpression: [ExpressionSegment]
	{
		// example: {% if IDENTIFIER %}
		return [.variable("conditional")]
	}

	override class var keyword: String
	{
		return "if"
	}

	override func parse(statement: String, using parser: TokenParser) throws
	{
		try super.parse(statement: statement, using: parser)

		guard let value = compiledExpression["conditional"] as? Token.Value else
		{
			throw Errors.missingArtifacts
		}

		if value != .bool(true)
		{
			// TODO: Add elsif and else tags when they're implemented
			skipUntil = [TagEndIf.self]
		}
	}
}

class TagEndIf: Tag
{
	override class var keyword: String
	{
		return "endif"
	}
}
