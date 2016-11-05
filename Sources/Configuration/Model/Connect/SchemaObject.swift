//
//  SchemaDescription.swift
//  Pods
//
//  Created by Tony Stone on 9/21/16.
//
//

import Swift

class SchemaObject : SchemaType {
    
    init(properties: [String : SchemaType]) {
        self.properties = properties
    }
    
    let properties: [String: SchemaType]
}

///
/// Custom String Printing
///
extension SchemaObject : CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable  {
    
    var description: String {
        return description(indent: 0)
    }
    
    var debugDescription: String {
        return description(indent: 0)
    }
    
    func description(indent: Int, indentFirst: Bool = true) -> String {
        
        var description = "\(String(repeating: "\t", count: indentFirst ? indent : 0)){"

        for (name, value) in self.properties {
            description.append("\r\(String(repeating: "\t", count: indent + 1))\(name):\(value.description(indent: indent + 1, indentFirst: false))")
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}

