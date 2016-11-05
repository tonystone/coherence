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
    case path
}
struct ParameterDescription : ConfigurationElement, IndentedStringConvertable  {

    init(name: String, location: ParameterLocation, type: SchemaPrimitiveType) {
        self.name = name
        self.location = location
        self.type = type
    }
    
    var id: String {
        return "\(name):\(location)"
    }
    
    let name: String
    let location: ParameterLocation
    let type: SchemaPrimitiveType
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
    
    func description(indent: Int, indentFirst: Bool = true) -> String {
        
        var description = "\(String(repeating: "\t", count: indentFirst ? indent : 0))parameter: {"
        
        description.append("\r\(String(repeating: "\t", count: indent + 1))name: '\(self.name)', type: '\(self.type.description(indent: indent, indentFirst: false))'")
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}
