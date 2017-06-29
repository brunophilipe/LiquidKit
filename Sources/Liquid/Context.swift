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
    
    public let environment: Environment
    
    init(dictionary: [String: Any]? = nil, environment: Environment? = nil) {
        if let dictionary = dictionary {
            dictionaries = dictionary
        } else {
            dictionaries = [:]
        }
        
        self.environment = environment ?? Environment()
    }
}

