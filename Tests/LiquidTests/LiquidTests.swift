//
//  LiquidTests.swift
//  LiquidTests
//
//  Created by YourtionGuo on 27/06/2017.
//

import XCTest
@testable import Liquid

#if os(Linux)
import SwiftGlibc
import Foundation
#endif

class LiquidTests: XCTestCase {
    func testLexer() { LexerTests().testTokenize() }

}

extension LiquidTests {
    static var allTests : [(String, (LiquidTests) -> () throws -> Void)] {
        return [
            ("testLexer", testLexer),
        ]
    }
}
