//
//  LiquidTests.swift
//  LiquidTests
//
//  Created by YourtionGuo on 27/06/2017.
//

import XCTest
@testable import LiquidKit

#if os(Linux)
import SwiftGlibc
import Foundation
#endif

class LiquidTests: XCTestCase {
  func testLexer() {
    LexerTests().testCreateToken()
    LexerTests().testTokenize()
  }
  func testParser()  {
    ParserTests().testParseText()
    ParserTests().testParseVariable()
  }

}

extension LiquidTests {
    static var allTests : [(String, (LiquidTests) -> () throws -> Void)] {
        return [
            ("testLexer", testLexer),
            ("testParser", testParser),
        ]
    }
}
