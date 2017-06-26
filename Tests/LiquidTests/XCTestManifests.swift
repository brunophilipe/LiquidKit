//
//  XCTestManifests.swift
//  LiquidTests
//
//  Created by YourtionGuo on 27/06/2017.
//

import XCTest

#if !os(OSX)
public func allTests() -> [XCTestCaseEntry] {
  return [
      testCase(LiquidTests.allTests)
  ]
}
#endif

