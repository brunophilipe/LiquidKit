//
//  Filter.swift
//  Liquid
//
//  Created by brunophilipe on 08/09/2018.
//
//

import Foundation

/// A class representing a template
open class Filter {

	/// Keyword used to identify the filter.
	let identifier: String

	/// Function that transforms the input string.
	let lambda: ((String, [String]) -> String)

	/// Filter constructor.
	init(identifier: String, lambda: @escaping (String, [String]) -> String) {
		self.identifier = identifier
		self.lambda = lambda
	}
}
