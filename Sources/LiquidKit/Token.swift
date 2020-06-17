//
//  Token.swift
//  Liquid
//
//  Created by YourtionGuo on 28/06/2017.
//
//

import Foundation

public enum Token : Equatable
{
    /// A token representing a piece of text.
    case text(value: String)
    
    /// A token representing a variable.
    case variable(value: String)
    
    /// A token representing a template tag.
    case tag(value: String)
    
    public static func ==(lhs: Token, rhs: Token) -> Bool
	{
        switch (lhs, rhs)
		{
        case (.text(let lhsValue), .text(let rhsValue)):			return lhsValue == rhsValue
        case (.variable(let lhsValue), .variable(let rhsValue)):	return lhsValue == rhsValue
        case (.tag(let lhsValue), .tag(let rhsValue)):				return lhsValue == rhsValue

		default:
            return false
        }
    }

	/// An enum whose instances are used to represent token variable values.
	public indirect enum Value: Hashable
	{
		case `nil`
		case bool(Bool)
		case string(String)
		case integer(Int)
		case decimal(Decimal)
		case array([Value])
		case dictionary([String: Value])
		case range(ClosedRange<Int>)

		/// Returns a string value or representation of the receiver.
		///
		/// * If the receiver is an integer or decimal enum, returns its value embedded in a string using `"\()"`.
		/// * If the receiver is a string enum, returns its value.
		/// * For any other enum value, returns an empty string.
		public var stringValue: String
		{
			switch self
			{
			case .decimal(let decimal): return "\(decimal)"
			case .integer(let integer): return "\(integer)"
			case .string(let string): return string
			case .array(let array): return array.compactMap({ $0.stringValue }).joined()
			case .range(let range): return "\(range.lowerBound)..\(range.upperBound)"
			default:
				 return ""
			}
		}

		/// Returns the decimal value of the receiver.
		///
		/// * If the receiver is an integer enum, returns its value cast to Decimal.
		/// * If the receiver is a decimal enum, returns its value.
		/// * If the receiver is a string enum, attempts to parse its value as a Decimal, which might return `nil`.
		/// * For any other enum value, returns `nil`.
		public var decimalValue: Decimal?
		{
			switch self
			{
			case .decimal(let decimal): return decimal
			case .integer(let integer): return Decimal(integer)
			case .string(let string): return Decimal(string: string)
			default:
				return nil
			}
		}

		/// Returns the double value of the receiver.
		///
		/// * If the receiver is an integer enum, returns its value cast to Double.
		/// * If the receiver is a decimal enum, returns its value cast to Double.
		/// * If the receiver is a string enum, attempts to parse its value as a Double, which might return `nil`.
		/// * For any other enum value, returns `nil`.
		public var doubleValue: Double?
		{
			switch self
			{
			case .decimal(let decimal): return NSDecimalNumber(decimal: decimal).doubleValue
			case .integer(let integer): return Double(integer)
			case .string(let string): return Double(string)
			default:
				return nil
			}
		}

		/// Returns the integer value of the receiver.
		///
		/// * If the receiver is an integer enum, returns its value.
		/// * If the receiver is a decimal enum, returns its value cast to Int.
		/// * If the receiver is a string enum, attempts to parse its value as an Int, which might return `nil`.
		/// * For any other enum value, returns `nil`.
		public var integerValue: Int?
		{
			switch self
			{
			case .decimal(let decimal): return NSDecimalNumber(decimal: decimal).intValue
			case .integer(let integer): return integer
			case .string(let string): return Int(string)
			default:
				return nil
			}
		}

		/// Returns `true` if the receiver is either `.nil` or `.bool(false)`. Otherwise returns `false`.
		public var isFalsy: Bool
		{
			switch self
			{
			case .bool(false), .nil:
				return true

			default:
				return false
			}
		}

		/// Returns `false` if the receiver is either `.nil` or `.bool(false)`. Otherwise returns `true`.
		public var isTruthy: Bool
		{
			return !isFalsy
		}

		/// Returns `true` if the receiver is a string enum and its value is an empty string. For all other cases
		/// returns `false`.
		public var isEmptyString: Bool
		{
			switch self
			{
			case .string(let string):
				return string.isEmpty

			default:
				return false
			}
		}

		public func hash(into hasher: inout Hasher)
		{
			switch self
			{
			case .nil:							hasher.combine(0)
			case .bool(let boolValue):			hasher.combine(boolValue)
			case .string(let stringValue):		hasher.combine(stringValue)
			case .integer(let integerValue):	hasher.combine(integerValue)
			case .decimal(let decimalValue):	hasher.combine(decimalValue)
			case .array(let arrayValue):		hasher.combine(arrayValue)
			case .dictionary(let dictValue):	hasher.combine(dictValue)
			case .range(let range):				hasher.combine(range)
			}
		}
	}
}

public protocol TokenValueConvertible
{
	var tokenValue: Token.Value { get }
}

extension Dictionary: TokenValueConvertible where Key == String, Value == TokenValueConvertible
{
	public var tokenValue: Token.Value
	{
		return .dictionary(mapValues({$0.tokenValue}))
	}
}

extension Array: TokenValueConvertible where Element: TokenValueConvertible
{
	public var tokenValue: Token.Value
	{
		return .array(map({$0.tokenValue}))
	}
}

extension Int: TokenValueConvertible
{
	public var tokenValue: Token.Value
	{
		return .integer(self)
	}
}

extension String: TokenValueConvertible
{
	public var tokenValue: Token.Value
	{
		return .string(self)
	}
}

extension Float: TokenValueConvertible
{
	public var tokenValue: Token.Value
	{
		return .decimal(Decimal(floatLiteral: Double(self)))
	}
}

extension Double: TokenValueConvertible
{
	public var tokenValue: Token.Value
	{
		return .decimal(Decimal(floatLiteral: self))
	}
}

extension Bool: TokenValueConvertible
{
	public var tokenValue: Token.Value
	{
		return .bool(self)
	}
}

extension Range: TokenValueConvertible where Bound: SignedInteger
{
	public var tokenValue: Token.Value
	{
		return .range(Int(lowerBound)...Int(upperBound - 1))
	}
}

extension ClosedRange: TokenValueConvertible where Bound: SignedInteger
{
	public var tokenValue: Token.Value
	{
		return .range(Int(lowerBound)...Int(upperBound))
	}
}
