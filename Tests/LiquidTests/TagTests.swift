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
		let context = Context()
		let tag = TagAssign(context: context)
		XCTAssertNoThrow(try tag.compile(from: "assign my_variable = \"bananas to the beat\""))
		XCTAssertEqual(context.getValue(for: "my_variable"), .string("bananas to the beat"))
	}
}
