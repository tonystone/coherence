//
//  SchemaPrimitiveType.swift
//  Pods
//
//  Created by Tony Stone on 9/24/16.
//
//

import Swift

protocol SchemaPrimitiveType : SchemaType, CustomStringConvertible, CustomDebugStringConvertible {
    
    init(required: Bool)
    
    var type: String { get }
    var required: Bool { get }
}

///
/// Custom String Printing
///
extension SchemaPrimitiveType {
    
    var description: String {
        return description(indent: 0)
    }
    
    var debugDescription: String {
        return description(indent: 0)
    }
    
    func description(indent indent: Int, indentFirst: Bool = true) -> String {
        return "\(String(repeating: "\t", count: indentFirst ? indent : 0)) \(self.type)\(self.required ? " *" : "")"
    }
}
