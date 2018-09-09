//
//  Context.swift
//  Liquid
//
//  Created by YourtionGuo on 28/06/2017.
//
//
/// A container for template variables.
public class Context {
    private var variables: [String: Filter.Value]

    public init(dictionary: [String: Filter.Value]? = nil) {
		variables = dictionary ?? [:]
    }
	
	public init(dictionary: [String: Any?]) {
		variables = [:]
		
		for (key, value) in dictionary {
			if let value = parseValue(value) {
				variables[key] = value
			}
		}
	}
	
	public func getValue(for key: String) -> Filter.Value? {
		return variables[key]
	}
	
	public func set(value: Filter.Value, for key: String) {
		variables[key] = value
	}
	
	public func set(value: Any?, for key: String) {
		
		if let value = parseValue(value) {
			variables[key] = value
		}
	}
	
	private func parseValue(_ value: Any?) -> Filter.Value? {
		if let intLiteral = value as? IntegerLiteralType {
			return .number(Decimal(integerLiteral: intLiteral))
		} else if let floatLiteral = value as? FloatLiteralType {
			return .number(Decimal(floatLiteral: floatLiteral))
		} else if let string = value as? String {
			return .string(string)
		} else if let boolLiteral = value as? BooleanLiteralType {
			return .bool(boolLiteral)
		} else if value == nil {
			return .nil
		} else {
			return nil
		}
	}
}

