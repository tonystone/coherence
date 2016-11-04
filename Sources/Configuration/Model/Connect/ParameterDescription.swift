//
//  ParameterDescription.swift
//  Pods
//
//  Created by Tony Stone on 10/22/16.
//
//

import Swift

///
/// Location of a specific parameter
///
enum ParameterLocation : String {
    case query
    case header
    case path
    case formData
    case body
}

protocol ParameterDescription : ConfigurationElement, CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable  {

    var name: String { get }
    var location: ParameterLocation { get }
    var type: SchemaType { get }
    var required: Bool { get }
}


///
/// Custom String Printing
///
extension ParameterDescription  {
    
    var description: String {
        return description(indent: 0)
    }
    
    var debugDescription: String {
        return description(indent: 0)
    }
    
    func description(indent indent: Int, indentFirst: Bool = true) -> String {
        
        var description = "\(String(repeating: "\t", count: indentFirst ? indent : 0))parameter: {"
        
        description.append("\r\(String(repeating: "\t", count: indent + 1))name: '\(self.name)', type: '\(self.type.description(indent: indent, indentFirst: false))', location: '\(self.location)', required: \(self.required ? "true" : "false"))")
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}
