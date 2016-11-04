//
//  MethodDescription.swift
//  Pods
//
//  Created by Tony Stone on 9/13/16.
//
//

import Swift

class OperationDescription : ConfigurationElement {
    
    ///
    /// MethodDescriptions must be complete on construction
    ///
    init(type: String, consumes: [MediaType], produces: [MediaType], parameters: [ParameterDescription], responses: [String : ResponseDescription]) {
        self.type = type
        self.consumes = consumes
        self.produces = produces
        self.parameters = parameters
        self.responses = responses
        
        self.resource = nil
    }

    var id: String {
        return "\(self.type)"
    }
    let type: String
    let consumes: [MediaType]
    let produces: [MediaType]
    let parameters: [ParameterDescription]
    let responses: [String : ResponseDescription]
    
    weak var resource: ResourceDescription?
}

///
/// Custom String Printing
///
extension OperationDescription : CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable  {
    
    var description: String {
        return description(indent: 0)
    }
    
    var debugDescription: String {
        return description(indent: 0)
    }
    
    func description(indent indent: Int, indentFirst: Bool = true) -> String {
        
        var description = "\(String(repeating: "\t", count: indentFirst ? indent : 0))operation: {"
        
        description.append("\r\(String(repeating: "\t", count: indent + 1))type: '\(type)', consumes: \(self.consumes), produces: \(self.produces)")
        
        for (code, response) in self.responses {
            description.append("\r\(code) {\r\(response.description(indent: indent + 1))\r\(String(repeating: "\t", count: indent + 1))}")
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}

