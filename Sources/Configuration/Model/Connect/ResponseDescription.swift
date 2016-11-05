//
//  ResponseDescription.swift
//  Pods
//
//  Created by Tony Stone on 9/19/16.
//
//
import Swift

class ResponseDescription : ConfigurationElement {
    
    init(code: String, headers: [String : String], content:  [MediaType : SchemaType]) {
        self.code = code
        self.headers = headers
        self.content = content
    }
    
    var id: String {
        return "\(self.code)"
    }
    let code: String
    let headers: [String : String]
    let content: [MediaType : SchemaType]
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
    
    func description(indent: Int, indentFirst: Bool = true) -> String {
        
        var description = "\(String(repeating: "\t", count: indentFirst ? indent : 0))response: {"
        
        description.append("\r\(String(repeating: "\t", count: indent + 1))code: '\(self.code)'")
        
        for (key, value) in self.headers {
            description.append("\r\(String(repeating: "\t", count: indent + 1))header: \(key) : \(value)")
        }
        
        for (_, schema) in self.content {
            description.append("\r\(String(repeating: "\t", count: indent + 1))schema: \(schema.description(indent: indent + 1, indentFirst: false))")
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}

