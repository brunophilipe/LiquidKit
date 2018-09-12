//
//  TagTests.swift
//  LiquidTests
//
//  Created by Bruno Philipe on 12/10/18.
//

import XCTest
@testable import Liquid

class TagTests: XCTestCase
{
	func testTagAssign()
	{
		let lexer = Lexer(templateString: "{% assign filename = \"/index.html\" %}{{ filename }}{% assign reversed = \"abc\" | split: \"\" | reverse | join: \"\" %}{{ reversed }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["/index.html", "cba"])
	}
}
