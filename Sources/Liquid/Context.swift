//
//  Context.swift
//  Liquid
//
//  Created by YourtionGuo on 28/06/2017.
//
//
/// A container for template variables.
public class Context {
    var dictionaries: [String: Any?]

    public init(dictionary: [String: Any]? = nil) {
        if let dictionary = dictionary {
            dictionaries = dictionary
        } else {
            dictionaries = [:]
        }
    }
}

