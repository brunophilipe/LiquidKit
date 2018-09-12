//
//  Double+Extensions.swift
//  LiquidTests
//
//  Created by Bruno Philipe on 10/09/18.
//

extension Double
{
	/// Given a number of significant digits `count`, returns a version of the receiver with that amount of decimal
	/// digits set.
	///
	/// - Parameter count: Number of significant decimal difgits to truncate the receiver to.
	/// - Returns: The truncated value
	func truncatingDecimals(to count: Int) -> Double
	{
		guard count >= 0 else
		{
			return self
		}

		return Double(String(format: "%.\(count)f", self)) ?? self
	}
}
