//
//  RequestDescription.swift
//  Pods
//
//  Created by Tony Stone on 11/4/16.
//
//
import Swift

class RequestDescription : ConfigurationElement {
    
    init(headers: [String : String], content: [MediaType : SchemaType]) {
        self.headers = headers
        self.content = content
    }
    
    var id: String {
        return ""
    }
    
    let headers: [String : String]
    let content: [MediaType : SchemaType]
}

///
/// Custom String Printing
///
extension RequestDescription : CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable  {
    
    var description: String {
        return description(indent: 0)
    }
    
    var debugDescription: String {
        return description(indent: 0)
    }
    
    func description(indent indent: Int, indentFirst: Bool = true) -> String {
        
        var description = "\(String(repeating: "\t", count: indentFirst ? indent : 0))response: {"
        
        for (key, value) in self.headers {
            description.append("\r\(String(repeating: "\t", count: indent + 1))header: \(key) : \(value)")
        }
        
        for (mediaType, schema) in self.content {
            description.append("\r\(String(repeating: "\t", count: indent + 1))schema: \(schema.description(indent: indent + 1, indentFirst: false))")
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}


