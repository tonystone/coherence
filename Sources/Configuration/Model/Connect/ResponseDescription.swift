//
//  ResponseDescription.swift
//  Pods
//
//  Created by Tony Stone on 9/19/16.
//
//

import Swift

class ResponseDescription : ConfigurationElement {
    
    init(code: String, schema: SchemaType?, headers: [ParameterDescription]) {
        self.code = code
        self.schema = schema
        self.headers = headers
    }
    
    var id: String {
        return "\(self.code)"
    }
    let code: String
    let schema: SchemaType?
    let headers: [ParameterDescription]
}

///
/// Custom String Printing
///
extension ResponseDescription : CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable  {
    
    var description: String {
        return description(indent: 0)
    }
    
    var debugDescription: String {
        return description(indent: 0)
    }
    
    func description(indent indent: Int, indentFirst: Bool = true) -> String {
        
        var description = "\(String(repeating: "\t", count: indentFirst ? indent : 0))response: {"
        
        description.append("\r\(String(repeating: "\t", count: indent + 1))code: '\(self.code)'")
        
        if let schema = self.schema {
            description.append("\r\(String(repeating: "\t", count: indent + 1))schema: \(schema.description(indent: indent + 1, indentFirst: false))")
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}

