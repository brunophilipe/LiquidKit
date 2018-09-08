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
    
}
