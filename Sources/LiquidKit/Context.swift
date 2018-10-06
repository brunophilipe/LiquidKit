//
//  Context.swift
//  Liquid
//
//  Created by YourtionGuo on 28/06/2017.
//
//
/// A container for template variables.
public class Context
{
    private var variables: [String: Token.Value]
	private var counters: [String: Int] = [:]

    public init(dictionary: [String: Token.Value]? = nil)
	{
		variables = dictionary ?? [:]
    }
	
	public init(dictionary: [String: Any?])
	{
		variables = [:]
		
		for (key, value) in dictionary
		{
			if let value = parseValue(value)
			{
				variables[key] = value
			}
		}
	}
	
	public func getValue(for key: String) -> Token.Value?
	{
		return variables[key]
	}
	
	public func set(value: Token.Value, for key: String)
	{
		variables[key] = value
	}
	
	public func set(value: Any?, for key: String)
	{
		
		if let value = parseValue(value)
		{
			variables[key] = value
		}
	}

	/// Creates a new number variable, and increases its value by one every time it is called. The initial value is 0.
	public func incrementCounter(for key: String) -> Int
	{
		let counter = counters[key] ?? 0
		counters[key] = counter + 1
		return counter
	}

	/// Creates a new number variable, and decreases its value by one every time it is called. The initial value is -1.
	public func decrementCounter(for key: String) -> Int
	{
		let counter = (counters[key] ?? 0) - 1
		counters[key] = counter
		return counter
	}
	
	private func parseValue(_ value: Any?) -> Token.Value?
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

	func valueOrLiteral(for token: String) -> Token.Value?
	{
		let trimmedToken = token.trimmingWhitespaces

		if trimmedToken == "true"
		{
			return .bool(true)
		}
		else if trimmedToken == "false"
		{
			return .bool(false)
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
		else if let value = getValue(for: trimmedToken)
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
}
