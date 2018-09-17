//
//  Operator.swift
//  LiquidKit
//
//  Created by Bruno Philipe on 9/16/18.
//

import Foundation

/// A class modeling an infix operator
open class Operator
{
	/// Keyword used to identify the filter.
	let identifier: String
	
	/// Function that transforms the input string.
	let lambda: ((Token.Value, Token.Value) -> Token.Value)
	
	/// Filter constructor.
	init(identifier: String, lambda: @escaping (Token.Value, Token.Value) -> Token.Value) {
		self.identifier = identifier
		self.lambda = lambda
	}
}

extension Operator
{
	static let equals = Operator(identifier: "==") { .bool($0 == $1) }
	static let notEquals = Operator(identifier: "!=") { .bool($0 != $1) }
	static let greaterThan = Operator(identifier: ">") { .bool($0.doubleValue ?? 0 > $1.doubleValue ?? 0) }
	static let lessThan = Operator(identifier: "<") { .bool($0.doubleValue ?? 0 < $1.doubleValue ?? 0) }
	static let greaterThanOrEquals = Operator(identifier: ">=") { .bool($0.doubleValue ?? 0 >= $1.doubleValue ?? 0) }
	static let lessThanOrEquals = Operator(identifier: "<=") { .bool($0.doubleValue ?? 0 <= $1.doubleValue ?? 0) }
	static let literalOr = Operator(identifier: "or") { .bool($0.isTruthy || $1.isTruthy) }
	static let literalAnd = Operator(identifier: "and") { .bool($0.isTruthy && $1.isTruthy) }
}
