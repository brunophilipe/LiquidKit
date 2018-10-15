//
//  TagTests.swift
//  LiquidTests
//
//  Created by Bruno Philipe on 12/10/18.
//

import XCTest
@testable import LiquidKit

class TagTests: XCTestCase
{
	func testTagAssign()
	{
		let lexer = Lexer(templateString: "{% assign filename = \"/index.html\" %}{{ filename }}{% assign reversed = \"abc\" | split: \"\" | reverse | join: \"\" %}{{ reversed }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["/index.html", "cba"])
	}

	func testTagIncrement()
	{
		let lexer = Lexer(templateString: "{% increment counter %}{% increment counter %}{% increment counter %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["0", "1", "2"])
	}

	func testTagDecrement()
	{
		let lexer = Lexer(templateString: "{% decrement counter %}{% decrement counter %}{% decrement counter %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["-1", "-2", "-3"])
	}

	func testTagIncrementDecrement()
	{
		let lexer = Lexer(templateString: "{% decrement counter %}{% decrement counter %}{% decrement counter %}{% increment counter %}{% increment counter %}{% increment counter %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["-1", "-2", "-3", "-3", "-2", "-1"])
	}

	func testTagIfEndIf()
	{
		let lexer = Lexer(templateString: "<p>{% assign check = false %}{% if check %}{% if check %}10{% endif %}20{% endif %}</p>")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["<p>", "</p>"])
	}

	func testTagIfEndIf_inverse()
	{
		let lexer = Lexer(templateString: "<p>{% assign check = true %}{% if check %}{% if check %}10{% endif %}20{% endif %}</p>")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["<p>", "10", "20", "</p>"])
	}

	func testTagIfRepeatedEsleIfEndIf()
	{
		let lexer = Lexer(templateString: "<p>{% assign check = 3 %}{% if check == 1 %}1{% elsif check == 2 %}2{% elsif check == 3 %}3{% elsif check == 3 %}4{% else %}5{% endif %}</p>")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["<p>", "3", "</p>"])
	}

	func testTagIfElseEndIf()
	{
		let lexer = Lexer(templateString: "<p>{% assign check = false %}{% if check %}10{% else %}20{% endif %}</p>")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["<p>", "20", "</p>"])
	}

	func testTagIfElseEndIf_inverse()
	{
		let lexer = Lexer(templateString: "<p>{% assign check = true %}{% if check %}10{% else %}20{% endif %}</p>")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["<p>", "10", "</p>"])
	}

	func testTagIfElseIfEndIf()
	{
		let lexer = Lexer(templateString: "<p>{% assign check = false %}{% assign check_inverse = true %}{% if check %}10{% elsif check_inverse %}20{% endif %}</p>")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["<p>", "20", "</p>"])
	}

	func testTagIfElseIfEndIf_inverse()
	{
		let lexer = Lexer(templateString: "<p>{% assign check = true %}{% assign check_inverse = false %}{% if check %}10{% elsif check_inverse %}20{% endif %}</p>")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["<p>", "10", "</p>"])
	}

	func testChainedTagElseIf()
	{
		let lexer = Lexer(templateString: "<p>{% assign check = false %}{% assign check_inverse = true %}{% if check %}10{% elsif check %}20{% elsif check_inverse %}30{% endif %}</p>")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["<p>", "30", "</p>"])
	}
	
	func testCaptureTag()
	{
		let lexer = Lexer(templateString: "{% capture my_variable %}I am being captured.{% endcapture %}\n{{ my_variable }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["\n", "I am being captured."])
	}

	func testTagUnlessEndUnless()
	{
		let lexer = Lexer(templateString: "<p>{% assign check = true %}{% unless check %}{% unless check %}10{% endunless %}20{% endunless %}</p>")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["<p>", "</p>"])
	}

	func testTagCaseWhen_1()
	{
		let lexer = Lexer(templateString: "<p>{% assign handle = 'cake' %}{% case handle %}rogue chars{% when 'cake' %}This is a cake{% when 'cookie' %}This is a cookie{% else %}This is not a cake nor a cookie{% endcase %}</p>")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["<p>", "This is a cake", "</p>"])
	}

	func testTagCaseWhen_2()
	{
		let lexer = Lexer(templateString: "<p>{% assign handle = 'cookie' %}{% case handle %}rogue chars{% when 'cake' %}This is a cake{% when 'cookie' %}This is a cookie{% else %}This is not a cake nor a cookie{% endcase %}</p>")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["<p>", "This is a cookie", "</p>"])
	}

	func testTagCaseWhenElse()
	{
		let lexer = Lexer(templateString: "<p>{% assign handle = 'croissant' %}{% case handle %}rogue chars{% when 'cake' %}This is a cake{% when 'cookie' %}This is a cookie{% else %}This is not a cake nor a cookie{% endcase %}</p>")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["<p>", "This is not a cake nor a cookie", "</p>"])
	}

	func testTagCaseEmpty()
	{
		let lexer = Lexer(templateString: "<p>{% assign handle = 'cake' %}{% case handle %}{% else %}This is not a cake nor a cookie{% endcase %}</p>")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["<p>", "This is not a cake nor a cookie", "</p>"])
	}
	
	func testTagRaw()
	{
		let lexer = Lexer(templateString: "{% raw %}In Handlebars, {{ this }} will be HTML-escaped, but {{{ that }}} will not.{% endraw %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["In Handlebars, {{ this }} will be HTML-escaped, but {{{ that }}} will not."])
	}

	func testTagFor()
	{
		let lexer = Lexer(templateString: "{% assign foodstuff = 'cake,coffee,biscuits' | split: ',' %}{% for food in foodstuff %}{{ food }}{% endfor %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["cake", "coffee", "biscuits"])
	}
	
	func testTagForElse()
	{
		let lexer = Lexer(templateString: "{% assign foodstuff = ',' | split: ',' %}{% for food in foodstuff %}{{ food }}{% else %}No food items!{% endfor %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["No food items!"])
	}
	
	func testTagForElseWithItems()
	{
		let lexer = Lexer(templateString: "{% assign foodstuff = 'cake,coffee,biscuits' | split: ',' %}{% for food in foodstuff %}{{ food }}{% else %}No food items!{% endfor %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["cake", "coffee", "biscuits"])
	}

	func testTagForNested()
	{
		let lexer = Lexer(templateString: "{% assign foodstuff = 'cake,coffee,biscuits' | split: ',' %}{% assign utensils = 'fork,spoon,mug' | split: ',' %}{% for food in foodstuff %}{{ food }}{% for utensil in utensils %}{{ utensil }}{% endfor %}{% else %}No food items!{% endfor %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["cake", "fork", "spoon", "mug", "coffee", "fork", "spoon", "mug", "biscuits", "fork", "spoon", "mug"])
	}

	func testTagForBreak()
	{
		let lexer = Lexer(templateString: "{% assign foodstuff = 'cake,coffee,biscuits' | split: ',' %}{% for food in foodstuff %}{{ food }}{% if food == 'coffee' %}{% break %}{% endif %}{% else %}No food items!{% endfor %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["cake", "coffee"])
	}

	func testTagForContinue()
	{
		let lexer = Lexer(templateString: "{% assign foodstuff = 'cake,coffee,biscuits' | split: ',' %}{% for food in foodstuff %}{% if food == 'coffee' %}{% continue %}{% endif %}{{ food }}{% else %}No food items!{% endfor %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["cake", "biscuits"])
	}

	func testTagForRange()
	{
		let lexer = Lexer(templateString: "{% assign digits = (3..5) %}{% for digit in digits %}{{ digit }}{% endfor %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["3", "4", "5"])
	}

	func testTagForLimit()
	{
		let lexer = Lexer(templateString: "{% assign foodstuff = 'cake,coffee,biscuits' | split: ',' %}{% for food in foodstuff limit:2 %}{{ food }}{% endfor %}{% for food in foodstuff limit : 2 %}{{ food }}{% endfor %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["cake", "coffee", "cake", "coffee"])
	}

	func testTagForOffset()
	{
		let lexer = Lexer(templateString: "{% assign foodstuff = 'cake,coffee,biscuits' | split: ',' %}{% for food in foodstuff offset:2 %}{{ food }}{% endfor %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["biscuits"])
	}

	func testTagForLimitOffset()
	{
		let lexer = Lexer(templateString: "{% assign foodstuff = 'cake,coffee,biscuits' | split: ',' %}{% for food in foodstuff offset:1 limit:1 %}{{ food }}{% endfor %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["coffee"])
	}

	func testTagForReversed()
	{
		let lexer = Lexer(templateString: "{% assign foodstuff = 'cake,coffee,biscuits' | split: ',' %}{% for food in foodstuff reversed %}{{ food }}{% endfor %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["biscuits", "coffee", "cake"])
	}

	func testTagForReversedLimitOffset()
	{
		let lexer = Lexer(templateString: "{% assign foodstuff = 'cake,coffee,biscuits,tea' | split: ',' %}{% for food in foodstuff reversed limit:1 offset:2 %}{{ food }}{% endfor %}{% for food in foodstuff reversed offset:2 limit:1 %}{{ food }}{% endfor %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["biscuits", "biscuits"])
	}

	func testTagForObject()
	{
		let lexer = Lexer(templateString: "{% assign foodstuff = 'cake,coffee,biscuits' | split: ',' %}{% for food in foodstuff %}{% if forloop.first == true %}First time through!{% else %}Not the first time.{% endif %}{% endfor %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["First time through!", "Not the first time.", "Not the first time."])
	}

	func testTagForObjectIndex()
	{
		let lexer = Lexer(templateString: "{% assign foodstuff = 'cake,coffee,biscuits' | split: ',' %}{% for food in foodstuff %}{{ forloop.index }}{{ forloop.rindex0 }}{% endfor %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["1", "2", "2", "1", "3", "0"])
	}

	func testTagCycle()
	{
		let lexer = Lexer(templateString: """
{% cycle 'one', 'two', 'three' %}
{% cycle 'one', 'two', 'three' %}
{% cycle 'one', 'two', 'three' %}
{% cycle 'one', 'two', 'three' %}
""")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["one", "\n", "two", "\n", "three", "\n", "one"])
	}

	func testTagCycleGrouped()
	{
		let lexer = Lexer(templateString: """
{% cycle 'one', 'two', 'three' group:'a' %}
{% cycle 'one', 'two', 'three' group:'b' %}
{% cycle 'one', 'two', 'three' group:'a' %}
{% cycle 'one', 'two', 'three' group:'b' %}
""")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["one", "\n", "one", "\n", "two", "\n", "two"])
	}

	func testTagTablerow()
	{
		let lexer = Lexer(templateString: "{% assign foodstuff = 'cake,coffee,biscuits' | split: ',' %}<table>{% tablerow food in foodstuff %}{{ food }}{% endtablerow %}</table>")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["<table>", "<tr class=\"row1\">", "<td class=\"col1\">", "cake", "</td>", "<td class=\"col2\">", "coffee", "</td>", "<td class=\"col3\">", "biscuits", "</td>", "</tr>", "</table>"])
	}

	func testTagTablerowCols()
	{
		let lexer = Lexer(templateString: "{% assign foodstuff = 'cake,coffee,biscuits' | split: ',' %}<table>{% tablerow food in foodstuff cols:2 %}{{ food }}{% endtablerow %}</table>")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["<table>", "<tr class=\"row1\">", "<td class=\"col1\">", "cake", "</td>", "<td class=\"col2\">", "coffee", "</td>", "</tr>", "<tr class=\"row2\">", "<td class=\"col1\">", "biscuits", "</td>", "</tr>", "</table>"])
	}

	func testTagComment()
	{
		let lexer = Lexer(templateString: "Anything you put between {% comment %} and {% endcomment %} tags is turned into a comment.")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = parser.parse()
		XCTAssertEqual(res, ["Anything you put between ", " tags is turned into a comment."])
	}
}
