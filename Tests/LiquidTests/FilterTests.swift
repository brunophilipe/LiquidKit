//
//  FilterTests.swift
//  LiquidTests
//
//  Created by Bruno Philipe on 10/09/18.
//

import XCTest
@testable import Liquid

class FilterTests: XCTestCase
{
	func testFilter_abs()
	{
		let lexer = Lexer(templateString: "{{ -7 | abs }}{{ 100 | abs }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["7", "100"])
	}
	
	func testFilter_append()
	{
		let lexer = Lexer(templateString: """
{% assign filename = \"/index.html\" %}
{{ \"/my/fancy/url\" | append: \".html\" }}
{{ \"a\" | append: \"b\" | append: \"c\" }}
{{ \"website.com\" | append: filename }}
""")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["\n", "/my/fancy/url.html", "\n", "abc", "\n", "website.com/index.html"])
	}
	
	func testFilter_atLeast()
	{
		let lexer = Lexer(templateString: "{{ 4 | at_least: 5 }}{{ 4 | at_least: 3 }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["5", "4"])
	}
	
	func testFilter_atMost()
	{
		let lexer = Lexer(templateString: "{{ 4 | at_most: 5 }}{{ 4 | at_most: 3 }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["4", "3"])
	}
	
	func testFilter_capitalize()
	{
		let lexer = Lexer(templateString: "{{ \"title\" | capitalize }}{{ \"my great title\" | capitalize }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Title", "My great title"])
	}
	
	func testFilter_ceil()
	{
		let lexer = Lexer(templateString: "{{ 1.2 | ceil }}{{ 2.0 | ceil }}{{ 183.357 | ceil }}{{ \"3.5\" | ceil }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["2", "2", "184", "4"])
	}
	
	func testFilter_date()
	{
		let lexer = Lexer(templateString: "{{ \"March 14, 2016\" | date: \"%b %d, %y\" }}{{ \"March 14, 2016\" | date: \"%a, %b %d, %y\" }}{{ \"March 14, 2016\" | date: \"%Y-%m-%d %H:%M\" }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Mar 14, 16", "Mon, Mar 14, 16", "2016-03-14 00:00"])
	}
	
	func testFilter_default()
	{
		let lexer = Lexer(templateString: "{{ the_number | default: \"42\" }}{{ \"the_number\" | default: \"42\" }}{{ \"\" | default: 42 }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["42", "the_number", "42"])
	}
	
	func testFilter_dividedBy()
	{
		let lexer = Lexer(templateString: "{{ 16 | divided_by: 4 }}{{ 5 | divided_by: 3 }}{{ 20 | divided_by: 7.0 }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["4", "1", "2.857142857142857728"])
	}
	
	func testFilter_downcase()
	{
		let lexer = Lexer(templateString: "{{ \"Parker Moore\" | downcase }}{{ \"apple\" | downcase }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["parker moore", "apple"])
	}
	
	func testFilter_escape()
	{
		let lexer = Lexer(templateString: "{{ \"Have you read 'James & the Giant Peach'?\" | escape }}{{ \"Tetsuro Takara\" | escape }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Have you read &apos;James &amp; the Giant Peach&apos;?", "Tetsuro Takara"])
	}
	
	func testFilter_escapeOnce()
	{
		let lexer = Lexer(templateString: "{{ \"1 < 2 & 3\" | escape_once }}{{ \"1 &lt; 2 &amp; 3\" | escape_once }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["1 &lt; 2 &amp; 3", "1 &lt; 2 &amp; 3"])
	}

	func testFilter_floor()
	{
		let lexer = Lexer(templateString: "{{ 1.2 | floor }}{{ 2.0 | floor }}{{ 183.357 | floor }}{{ \"3.5\" | floor }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["1", "2", "183", "3"])
	}

	func testFilter_leftStrip()
	{
		let lexer = Lexer(templateString: "{{ \"          So much room for activities!          \" | lstrip }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["So much room for activities!          "])
	}

	func testFilter_minus()
	{
		let lexer = Lexer(templateString: "{{ 4 | minus: 2 }}{{ 16 | minus: 4 }}{{ 183.357 | minus: 12 }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["2", "12", "171.357"])
	}

	func testFilter_modulo()
	{
		let lexer = Lexer(templateString: "{{ 3 | modulo: 2 }}{{ 24 | modulo: 7 }}{{ 183.357 | modulo: 12 }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["1", "3", "3.357000000000028672"])
	}

	func testFilter_newlineToBr()
	{
		let lexer = Lexer(templateString: "{{ \"\nHello\r\nthere\n\" | newline_to_br }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["<br />Hello<br />there<br />"])
	}

	func testFilter_plus()
	{
		let lexer = Lexer(templateString: "{{ 4 | plus: 2 }}{{ 16 | plus: 4 }}{{ 183.357 | plus: 12 }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["6", "20", "195.357"])
	}

	func testFilter_prepend()
	{
		let lexer = Lexer(templateString: "{{ \"apples, oranges, and bananas\" | prepend: \"Some fruit: \" }}{{ \"a\" | prepend: \"b\" | prepend: \"c\" }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Some fruit: apples, oranges, and bananas", "cba"])

		// TODO:
//		{% assign url = "liquidmarkup.com" %}
//		{{ "/index.html" | prepend: url }}
	}

	func testFilter_remove()
	{
		let lexer = Lexer(templateString: "{{ \"I strained to see the train through the rain\" | remove: \"rain\" }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["I sted to see the t through the "])
	}

	func testFilter_removeFirst()
	{
		let lexer = Lexer(templateString: "{{ \"I strained to see the train through the rain\" | remove_first: \"rain\" }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["I sted to see the train through the rain"])
	}

	func testFilter_replace()
	{
		let lexer = Lexer(templateString: "{{ \"Take my protein pills and put my helmet on\" | replace: \"my\", \"your\" }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Take your protein pills and put your helmet on"])
	}

	func testFilter_replaceFirst()
	{
		let lexer = Lexer(templateString: "{{ \"Take my protein pills and put my helmet on\" | replace_first: \"my\", \"your\" }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Take your protein pills and put my helmet on"])
	}

	func testFilter_reverse()
	{
		let lexer = Lexer(templateString: "{{ \"apples, oranges, peaches, plums\" | split: \", \" | reverse | join: \", \" }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["plums, peaches, oranges, apples"])
	}

	func testFilter_round()
	{
		let lexer = Lexer(templateString: "{{ 1.2 | round }}{{ 2.7 | round }}{{ 183.357 | round: 2 }}{{ \"3.5\" | round }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["1", "3", "183.36", "4"])
	}

	func testFilter_rightStrip()
	{
		let lexer = Lexer(templateString: "{{ \"          So much room for activities!          \" | rstrip }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["          So much room for activities!"])
	}

	func testFilter_size()
	{
		let lexer = Lexer(templateString: "{{ \"apples, oranges, peaches, plums\" | split: \", \" | size }}{{ \"Ground control to Major Tom.\" | size }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["4", "28"])
	}

	func testFilter_slice()
	{
		let lexer = Lexer(templateString: "{{ \"Liquid\" | slice: 0 }}{{ \"Liquid\" | slice: 2 }}{{ \"Liquid\" | slice: 2, 5 }}{{ \"Liquid\" | slice: -3, 2 }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["L", "q", "quid", "ui"])
	}

	func testFilter_sort()
	{
		let lexer = Lexer(templateString: "{{ \"zebra, octopus, giraffe, Sally Snake\" | split: \", \" | sort | join: \", \" }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Sally Snake, giraffe, octopus, zebra"])
	}

	func testFilter_sortNatural()
	{
		let lexer = Lexer(templateString: "{{ \"zebra, octopus, giraffe, Sally Snake\" | split: \", \" | sort_natural | join: \", \" }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["giraffe, octopus, Sally Snake, zebra"])
	}

	func testFilter_split()
	{
		let lexer = Lexer(templateString: "{{ \"banana\" | split: \"\" | join: \"-\" }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["b-a-n-a-n-a"])
	}

	func testFilter_split_join()
	{
		let lexer = Lexer(templateString: "{{ \"John, Paul, George, Ringo\" | split: \", \" | join: \"-\" }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["John-Paul-George-Ringo"])
	}

	func testFilter_strip()
	{
		let lexer = Lexer(templateString: "{{ \"          So much room for activities!          \" | strip }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["So much room for activities!"])
	}

	func testFilter_stripHTML()
	{
		let lexer = Lexer(templateString: "{{ \"Have <em>you</em> read <strong>Ulysses</strong>?\" | strip_html }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Have you read Ulysses?"])
	}

	func testFilter_stripNewlines()
	{
		let lexer = Lexer(templateString: "{{ \"Hello\nthere\n\" | strip_newlines }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Hellothere"])
	}

	func testFilter_times()
	{
		let lexer = Lexer(templateString: "{{ 3 | times: 2 }}{{ 24 | times: 7 }}{{ 183.357 | times: 12 }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["6", "168", "2200.284"])
	}

	func testFilter_truncate()
	{
		let lexer = Lexer(templateString: "{{ \"Ground control to Major Tom.\" | truncate: 20 }}{{ \"Ground control to Major Tom.\" | truncate: 25, \", and so on\" }}{{ \"Ground control to Major Tom.\" | truncate: 20, \"\" }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Ground control to...", "Ground control, and so on", "Ground control to Ma"])
	}

	func testFilter_truncateWords()
	{
		let lexer = Lexer(templateString: "{{ \"Ground control to Major Tom.\" | truncatewords: 3 }}{{ \"Ground control to Major Tom.\" | truncatewords: 4, \"--\" }}{{ \"Ground control to Major Tom.\" | truncatewords: 2, \"\" }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Ground control to...", "Ground control to Major--", "Ground control"])
	}

	func testFilter_uniq()
	{
		let lexer = Lexer(templateString: "{{ \"ants, bugs, bees, bugs, ants\" | split: \", \" | uniq | join: \", \" }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["ants, bugs, bees"])
	}

	func testFilter_upcase()
	{
		let lexer = Lexer(templateString: "{{ \"Parker Moore\" | upcase }}{{ \"APPLE\" | upcase }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["PARKER MOORE", "APPLE"])
	}

	func testFilter_urlDecode()
	{
		let lexer = Lexer(templateString: "{{ \"%27Stop%21%27+said+Fred\" | url_decode }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["'Stop!' said Fred"])
	}

	func testFilter_urlEncode()
	{
		let lexer = Lexer(templateString: "{{ \"john@liquid.com\" | url_encode }}{{ \"Tetsuro Takara\" | url_encode }}")
		let tokens = lexer.tokenize()
		let parser = TokenParser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["john%40liquid.com", "Tetsuro+Takara"])
	}
}
