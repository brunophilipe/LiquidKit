//
//  OperatorTests.swift
//  LiquidKitTests
//
//  Created by Bruno Philipe on 18/9/18.
//

import XCTest
@testable import LiquidKit

class OperatorTests: XCTestCase
{
	func testEquals()
	{
		let lexer = Lexer(templateString: "{% assign filename = \"/index.html\" %}{% if filename == \"/index.html\" %}TRUE{% else %}FALSE{% endif %}{% if filename == 10 %}TRUE{% else %}FALSE{% endif %}{% if filename %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["TRUE", "FALSE", "TRUE"])
	}

	func testNotEquals()
	{
		let lexer = Lexer(templateString: "{% assign filename = \"/index.html\" %}{% if filename != \"/index.html\" %}TRUE{% else %}FALSE{% endif %}{% if filename != 10 %}TRUE{% else %}FALSE{% endif %}{% if 30 != 10 %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["FALSE", "TRUE", "TRUE"])
	}

	func testGreaterThan()
	{
		let lexer = Lexer(templateString: "{% assign size = 650 %}{% if size > 100 %}TRUE{% else %}FALSE{% endif %}{% if size > 987 %}TRUE{% else %}FALSE{% endif %}{% if size > 650 %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["TRUE", "FALSE", "FALSE"])
	}

	func testLessThan()
	{
		let lexer = Lexer(templateString: "{% assign size = 650 %}{% if size < 100 %}TRUE{% else %}FALSE{% endif %}{% if size < 987 %}TRUE{% else %}FALSE{% endif %}{% if size < 650 %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["FALSE", "TRUE", "FALSE"])
	}

	func testLessThanOrEquals()
	{
		let lexer = Lexer(templateString: "{% assign size = 650 %}{% if size <= 100 %}TRUE{% else %}FALSE{% endif %}{% if size <= 987 %}TRUE{% else %}FALSE{% endif %}{% if size <= 650 %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["FALSE", "TRUE", "TRUE"])
	}

	func testGreaterThanOrEquals()
	{
		let lexer = Lexer(templateString: "{% assign size = 650 %}{% if size >= 100 %}TRUE{% else %}FALSE{% endif %}{% if size >= 987 %}TRUE{% else %}FALSE{% endif %}{% if size >= 650 %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["TRUE", "FALSE", "TRUE"])
	}

	func testContains()
	{
		let lexer = Lexer(templateString: "{% assign words = \"alpha,beta,charlie\" | split: \",\" %}{% if words contains \"alpha\" %}TRUE{% else %}FALSE{% endif %}{% if words contains \"delta\" %}TRUE{% else %}FALSE{% endif %}{% if \"astronomy\" contains \"tron\" %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["TRUE", "FALSE", "TRUE"])
	}
}
