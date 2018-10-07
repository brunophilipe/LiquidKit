//
//  NSRegularExpression+Additions.swift
//  LiquidKit
//
//  Created by Bruno Philipe on 7/10/18.
//

import Foundation

extension NSRegularExpression
{
	static var rangeRegex = try! NSRegularExpression(pattern: "\\(([^\\.\\n]+)\\.\\.([^\\.\\n]+)\\)", options: [])

	static func tagParameterRegex(for name: String) -> NSRegularExpression
	{
		return try! NSRegularExpression(pattern: "\(name)(\\s*?:\\s*?(\\w+))?", options: [])
	}
}
