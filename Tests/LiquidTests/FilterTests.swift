//
//  FilterTests.swift
//  LiquidTests
//
//  Created by Bruno Philipe on 9/10/18.
//

import XCTest
@testable import Liquid

class FilterTests: XCTestCase
{
	func testFilter_abs()
	{
		let lexer = Lexer(templateString: "{{ -7 | abs }}{{ 100 | abs }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["7", "100"])
	}
	
	func testFilter_append()
	{
		let lexer = Lexer(templateString: "{{ \"/my/fancy/url\" | append: \".html\" }}{{ \"a\" | append: \"b\" | append: \"c\" }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["/my/fancy/url.html", "abc"])
		
		// TODO:
//		{% assign filename = "/index.html" %}
//		{{ "website.com" | append: filename }}
	}
	
	func testFilter_atLeast()
	{
		let lexer = Lexer(templateString: "{{ 4 | at_least: 5 }}{{ 4 | at_least: 3 }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["5", "4"])
	}
	
	func testFilter_atMost()
	{
		let lexer = Lexer(templateString: "{{ 4 | at_most: 5 }}{{ 4 | at_most: 3 }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["4", "3"])
	}
	
	func testFilter_capitalize()
	{
		let lexer = Lexer(templateString: "{{ \"title\" | capitalize }}{{ \"my great title\" | capitalize }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Title", "My great title"])
	}
	
	func testFilter_ceil()
	{
		let lexer = Lexer(templateString: "{{ 1.2 | ceil }}{{ 2.0 | ceil }}{{ 183.357 | ceil }}{{ \"3.5\" | ceil }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["2", "2", "184", "4"])
	}
	
	func testFilter_date()
	{
		let lexer = Lexer(templateString: "{{ \"March 14, 2016\" | date: \"%b %d, %y\" }}{{ \"March 14, 2016\" | date: \"%a, %b %d, %y\" }}{{ \"March 14, 2016\" | date: \"%Y-%m-%d %H:%M\" }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Mar 14, 16", "Mon, Mar 14, 16", "2016-03-14 00:00"])
	}
	
	func testFilter_default()
	{
		let lexer = Lexer(templateString: "{{ the_number | default: \"42\" }}{{ \"the_number\" | default: \"42\" }}{{ \"\" | default: 42 }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["42", "the_number", "42"])
	}
	
	func testFilter_dividedBy()
	{
		let lexer = Lexer(templateString: "{{ 16 | divided_by: 4 }}{{ 5 | divided_by: 3 }}{{ 20 | divided_by: 7.0 }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["4", "1", "2.857142857142857728"])
	}
	
	func testFilter_downcase()
	{
		let lexer = Lexer(templateString: "{{ \"Parker Moore\" | downcase }}{{ \"apple\" | downcase }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["parker moore", "apple"])
	}
	
	func testFilter_escape()
	{
		let lexer = Lexer(templateString: "{{ \"Have you read 'James & the Giant Peach'?\" | escape }}{{ \"Tetsuro Takara\" | escape }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Have you read &apos;James &amp; the Giant Peach&apos;?", "Tetsuro Takara"])
	}
	
	func testFilter_escapeOnce()
	{
		let lexer = Lexer(templateString: "{{ \"1 < 2 & 3\" | escape_once }}{{ \"1 &lt; 2 &amp; 3\" | escape_once }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["1 &lt; 2 &amp; 3", "1 &lt; 2 &amp; 3"])
	}

	func testFilter_floor()
	{
		let lexer = Lexer(templateString: "{{ 1.2 | floor }}{{ 2.0 | floor }}{{ 183.357 | floor }}{{ \"3.5\" | floor }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["1", "2", "183", "3"])
	}

	func testFilter_leftStrip()
	{
		let lexer = Lexer(templateString: "{{ \"          So much room for activities!          \" | lstrip }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["So much room for activities!          "])
	}

	func testFilter_minus()
	{
		let lexer = Lexer(templateString: "{{ 4 | minus: 2 }}{{ 16 | minus: 4 }}{{ 183.357 | minus: 12 }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["2", "12", "171.357"])
	}

	func testFilter_modulo()
	{
		let lexer = Lexer(templateString: "{{ 3 | modulo: 2 }}{{ 24 | modulo: 7 }}{{ 183.357 | modulo: 12 }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["1", "3", "3.357000000000028672"])
	}

	func testFilter_newlineToBr()
	{
		let lexer = Lexer(templateString: "{{ \"\nHello\r\nthere\n\" | newline_to_br }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["<br />Hello<br />there<br />"])
	}

	func testFilter_plus()
	{
		let lexer = Lexer(templateString: "{{ 4 | plus: 2 }}{{ 16 | plus: 4 }}{{ 183.357 | plus: 12 }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["6", "20", "195.357"])
	}

	func testFilter_prepend()
	{
		let lexer = Lexer(templateString: "{{ \"apples, oranges, and bananas\" | prepend: \"Some fruit: \" }}{{ \"a\" | prepend: \"b\" | prepend: \"c\" }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Some fruit: apples, oranges, and bananas", "cba"])

		// TODO:
//		{% assign url = "liquidmarkup.com" %}
//		{{ "/index.html" | prepend: url }}
	}

	func testFilter_remove()
	{
		let lexer = Lexer(templateString: "{{ \"I strained to see the train through the rain\" | remove: \"rain\" }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["I sted to see the t through the "])
	}

	func testFilter_removeFirst()
	{
		let lexer = Lexer(templateString: "{{ \"I strained to see the train through the rain\" | remove_first: \"rain\" }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["I sted to see the train through the rain"])
	}

	func testFilter_replace()
	{
		let lexer = Lexer(templateString: "{{ \"Take my protein pills and put my helmet on\" | replace: \"my\", \"your\" }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Take your protein pills and put your helmet on"])
	}
	
	func testFilter_split_join()
	{
		let lexer = Lexer(templateString: "{{ \"John, Paul, George, Ringo\" | split: \", \" | join: \"-\" }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["John-Paul-George-Ringo"])
	}
}
