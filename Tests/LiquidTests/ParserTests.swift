//
//  ParserTests.swift
//  Liquid
//
//  Created by YourtionGuo on 28/06/2017.
//
//

import XCTest
@testable import Liquid

class ParserTests: XCTestCase {
    
    func testParseText() {
        let lexer = Lexer(templateString: "aab  cc dd")
        let tokenize = lexer.tokenize()
        let parser = TokenParser(tokens: tokenize, context: Context())
        let res = parser.parse()
        XCTAssertEqual(res, ["aab  cc dd"])
    }
    
    func testParseVariable() {
        let dic = ["a": "A", "b": "BB", "c": "CCcCC"]
        let lexer = Lexer(templateString: "aab {{ a }} {{b}}c{{c}} d")
        let tokenize = lexer.tokenize()
        let parser = TokenParser(tokens: tokenize, context: Context(dictionary: dic))
        let res = parser.parse()
        XCTAssertEqual(res, ["aab ", "A", " ","BB","c", "CCcCC"," d"])
    }
    
    func testParseVariablePerformance() {
        let dic = ["a": "A", "b": "BB", "c": "CCcCC"]
        let lexer = Lexer(templateString: "aab {{ a }} {{b}}c{{c}} d")
        let tokenize = lexer.tokenize()
        let parser = TokenParser(tokens: tokenize, context: Context(dictionary: dic))
        measure {
            _ = parser.parse()
        }
    }

	func testFilter_abs() {
		let lexer = Lexer(templateString: "{{ -7 | abs }}{{ 100 | abs }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["7", "100"])
	}

	func testFilter_append() {
		let lexer = Lexer(templateString: "{{ \"/my/fancy/url\" | append: \".html\" }}{{ \"a\" | append: \"b\" | append: \"c\" }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["/my/fancy/url.html", "abc"])

		// TODO:
//		{% assign filename = "/index.html" %}
//		{{ "website.com" | append: filename }}
	}

	func testFilter_atLeast() {
		let lexer = Lexer(templateString: "{{ 4 | at_least: 5 }}{{ 4 | at_least: 3 }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["5", "4"])
	}

	func testFilter_atMost() {
		let lexer = Lexer(templateString: "{{ 4 | at_most: 5 }}{{ 4 | at_most: 3 }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["4", "3"])
	}

	func testFilter_capitalize() {
		let lexer = Lexer(templateString: "{{ \"title\" | capitalize }}{{ \"my great title\" | capitalize }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Title", "My great title"])
	}

	func testFilter_ceil() {
		let lexer = Lexer(templateString: "{{ 1.2 | ceil }}{{ 2.0 | ceil }}{{ 183.357 | ceil }}{{ \"3.5\" | ceil }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["2", "2", "184", "4"])
	}

	func testFilter_date() {
		let lexer = Lexer(templateString: "{{ \"March 14, 2016\" | date: \"%b %d, %y\" }}{{ \"March 14, 2016\" | date: \"%a, %b %d, %y\" }}{{ \"March 14, 2016\" | date: \"%Y-%m-%d %H:%M\" }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Mar 14, 16", "Mon, Mar 14, 16", "2016-03-14 00:00"])
	}
	
	func testFilter_default() {
		let lexer = Lexer(templateString: "{{ the_number | default: \"42\" }}{{ \"the_number\" | default: \"42\" }}{{ \"\" | default: 42 }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["42", "the_number", "42"])
	}

	func testFilter_dividedBy() {
		let lexer = Lexer(templateString: "{{ 16 | divided_by: 4 }}{{ 5 | divided_by: 3 }}{{ 20 | divided_by: 7.0 }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["4", "1", "2.857142857142857728"])
	}

	func testFilter_downcase() {
		let lexer = Lexer(templateString: "{{ \"Parker Moore\" | downcase }}{{ \"apple\" | downcase }}")
		let tokenize = lexer.tokenize()
		let parser = TokenParser(tokens: tokenize, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["parker moore", "apple"])
	}
}
