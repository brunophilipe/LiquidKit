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

	func testTagIncrement()
	{
		let lexer = Lexer(templateString: "{% increment counter %}{% increment counter %}{% increment counter %}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["0", "1", "2"])
	}

	func testTagDecrement()
	{
		let lexer = Lexer(templateString: "{% decrement counter %}{% decrement counter %}{% decrement counter %}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["-1", "-2", "-3"])
	}

	func testTagIncrementDecrement()
	{
		let lexer = Lexer(templateString: "{% decrement counter %}{% decrement counter %}{% decrement counter %}{% increment counter %}{% increment counter %}{% increment counter %}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["-1", "-2", "-3", "-3", "-2", "-1"])
	}

	func testTagIfEndIf()
	{
		let lexer = Lexer(templateString: "<p>{% assign check = false %}{% if check %}10{% endif %}</p>")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["<p>", "</p>"])
	}
}
