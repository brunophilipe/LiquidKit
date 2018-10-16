//
//  Context.swift
//  Liquid
//
//  Created by YourtionGuo on 28/06/2017.
//
//
/// A container for template variables.
open class Context
{
    private var variables: [String: Token.Value]
	private var counters: [String: Int] = [:]
	private var groups: [Int: (originalHash: Int, iterator: IndexingIterator<[Token.Value]>)] = [:]

    public init(dictionary: [String: Token.Value]? = nil)
	{
		variables = dictionary ?? [:]
    }
	
	public init(dictionary: [String: Any?])
	{
		self.variables = dictionary.mapValues({ Context.parseAny($0) }).filter({ $0.value != nil }).mapValues({ $0! })
	}
	
	open func getValue(for key: String) -> Token.Value?
	{
		return variables[key]
	}
	
	open func set(value: Token.Value, for key: String)
	{
		variables[key] = value
	}
	
	open func set(value: Any?, for key: String)
	{
		if let value = Context.parseAny(value)
		{
			variables[key] = value
		}
	}

	/// Creates a new number variable, and increases its value by one every time it is called. The initial value is 0.
	open func incrementCounter(for key: String) -> Int
	{
		let counter = counters[key] ?? 0
		counters[key] = counter + 1
		return counter
	}

	/// Creates a new number variable, and decreases its value by one every time it is called. The initial value is -1.
	open func decrementCounter(for key: String) -> Int
	{
		let counter = (counters[key] ?? 0) - 1
		counters[key] = counter
		return counter
	}

	/// Returns the next element in a group of token values. If an identifier is provided, that identifier is used to
	/// uniquely cycle through the group separately from other groups. If no identifier is provided, then it is assumed
	/// that multiple calls with the same group of token values are one group.
	open func next(in group: [Token.Value], identifier: String?) -> Token.Value?
	{
		let hash = identifier?.hashValue ?? group.hashValue

		if groups[hash]?.originalHash == hash, let next = groups[hash]?.iterator.next()
		{
			return next
		}

		groups[hash] = (hash, group.makeIterator())

		return groups[hash]?.iterator.next()
	}
	
	private static func parseAny(_ value: Any?) -> Token.Value?
	{
		if let intLiteral = value as? IntegerLiteralType
		{
			return .decimal(Decimal(integerLiteral: intLiteral))
		}
		else if let floatLiteral = value as? FloatLiteralType
		{
			return .decimal(Decimal(floatLiteral: floatLiteral))
		}
		else if let string = value as? String
		{
			return .string(string)
		}
		else if let boolLiteral = value as? BooleanLiteralType
		{
			return .bool(boolLiteral)
		}
		else if value == nil
		{
			return .nil
		}
		else
		{
			return nil
		}
	}

	internal func parseString(_ token: String, onlyIfLiteral: Bool = false) -> Token.Value?
	{
		let trimmedToken = token.trimmingWhitespaces
		let nsToken = token as NSString

		if trimmedToken == "true"
		{
			return .bool(true)
		}
		else if trimmedToken == "false"
		{
			return .bool(false)
		}
		else if let result = NSRegularExpression.rangeRegex.firstMatch(in: token, options: [],
																	   range: NSMakeRange(0, nsToken.length)),
			result.numberOfRanges == 3,
			let lowerBound = parseString(nsToken.substring(with: result.range(at: 1)))?.integerValue,
			let upperBound = parseString(nsToken.substring(with: result.range(at: 2)))?.integerValue
		{
			return .range(lowerBound...upperBound)
		}
		else if trimmedToken.hasPrefix("\""), trimmedToken.hasSuffix("\"")
		{
			// This is a literal string. Strip its double-quotations.
			return .string(trimmedToken.trim(character: "\""))
		}
		else if trimmedToken.hasPrefix("'"), trimmedToken.hasSuffix("'")
		{
			// This is a literal string. Strip its quotations.
			return .string(trimmedToken.trim(character: "'"))
		}
		else if let integer = Int(trimmedToken)
		{
			// This is an integer literal (the integer constructor fails if a decimal point is found).
			return .integer(integer)
		}
		else if !onlyIfLiteral, trimmedToken.contains("."), let value = variables.valueFor(keyPath: trimmedToken)
		{
			return value
		}
		else if !onlyIfLiteral, let value = getValue(for: trimmedToken)
		{
			// This is a known variable name.
			return value
		}
		else if let number = Decimal(string: trimmedToken)
		{
			// This is a decimal literal. Decimal needs to be evaluated last because the string initializer might match
			// strings such as "everything", which might be defined as context variables.
			return .decimal(number)
		}
		else
		{
			return nil
		}
	}
}

extension Context
{
	public func makeSupplement(with variables: [String: Token.Value]) -> Context
	{
		return SupplementalContext(supplemented: self, variables: variables)
	}
}

private extension Dictionary where Key == String, Value == Token.Value
{
	/// Returns the value associated with the traversal of the receiver's substructure using the given keypath.
	func valueFor(keyPath: String) -> Token.Value?
	{
		guard let (key, index, remainder) = keyPath.splitKeyPath, let value = self[key] else
		{
			return nil
		}

		switch (value, index, remainder)
		{
		case (.array(let array), .some(let index), nil) where (0..<array.count).contains(index):
			return array[index]

		case (.array(let array), .some(let index), .some(let remainder)) where (0..<array.count).contains(index):
			guard case .dictionary(let dictionary) = array[index] else
			{
				return nil
			}

			return dictionary.valueFor(keyPath: remainder)

		case (.array(let array), nil, .some(let remainder)) where remainder.hasPrefix("first"):
			let rangeFirst = remainder.range(of: "first\\.?", options: .regularExpression)!

			if rangeFirst.upperBound == remainder.endIndex
			{
				return array.first
			}
			else if case .some(.dictionary(let dictionary)) = array.first
			{
				return dictionary.valueFor(keyPath: String(remainder[rangeFirst.upperBound...]))
			}
			else
			{
				return nil
			}

		case (.array(let array), nil, .some(let remainder)) where remainder.hasPrefix("last"):
			let rangeLast = remainder.range(of: "last\\.?", options: .regularExpression)!

			if rangeLast.upperBound == remainder.endIndex
			{
				return array.last
			}
			else if case .some(.dictionary(let dictionary)) = array.last
			{
				return dictionary.valueFor(keyPath: String(remainder[rangeLast.upperBound...]))
			}
			else
			{
				return nil
			}

		case (.dictionary, nil, nil):
			return value

		case (.dictionary(let dictionary), nil, .some(let remainder)):
			return dictionary.valueFor(keyPath: remainder)

		case (_, nil, nil):
			return value

		default:
			return nil
		}
	}
}

/// A context that provides supplemental read-only variables to the parser. This is used, for instance,
/// to provide the current element variable which is available inside each iteration of a for loop.
private class SupplementalContext: Context
{
	private var supplementedContext: Context

	/// Defines a supplemental context.
	///
	/// - Parameters:
	///   - supplemented: The context to be supplemented.
	///   - variables: The variables that are only available in the supplemental context.
	init(supplemented: Context, variables: [String: Token.Value])
	{
		self.supplementedContext = supplemented
		super.init(dictionary: variables)
	}

	/// Returns the value for the given key in the supplemental context, if defined. Otherwise returns the value for
	/// the given key in the supplemented context, if defined.
	override func getValue(for key: String) -> Token.Value?
	{
		return super.getValue(for: key) ?? supplementedContext.getValue(for: key)
	}

	/// Sets the value for a key in the supplemented context.
	override func set(value: Token.Value, for key: String)
	{
		supplementedContext.set(value: value, for: key)
	}

	/// Increments a counter in the supplemented context, and returns its new value.
	override func incrementCounter(for key: String) -> Int
	{
		return supplementedContext.incrementCounter(for: key)
	}

	/// Decrements a counter in the supplemented context, and returns its new value.
	override func decrementCounter(for key: String) -> Int
	{
		return supplementedContext.decrementCounter(for: key)
	}

	/// Returns the next element in a group of token values in the supplemented context.
	override func next(in group: [Token.Value], identifier: String?) -> Token.Value?
	{
		return supplementedContext.next(in: group, identifier: identifier)
	}
}
