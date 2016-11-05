//
//  ResourceDescription.swift
//  Pods
//
//  Created by Tony Stone on 9/12/16.
//
//

import Swift

class ResourceDescription : ConfigurationElement {
    
    ///
    /// ResourceDescriptions must be complete on construction
    ///
    init(path: String, parameters: [ParameterDescription], operations: [OperationDescription]) {
        self.service = nil
        self.path = path
        self.parameters = parameters
        
        self._operations = []
        
        for operation in operations {
            operation.resource = self
        }
        self._operations = operations
    }

    var id: String {
        return "\(self.path)"
    }
    let path: String
    
    weak var service: ServiceDescription?

    let parameters: [ParameterDescription]
    var operations: [OperationDescription] {
        return _operations
    }
    private var _operations: [OperationDescription]
    
    ///
    /// Returns: A fully qualified URL for the resource described by this ResourceDescription
    ///
    func url(parameters: [String : Any]) -> URL {
        return URL(fileURLWithPath: "")
    }
}

///
/// Custom String Printing
///
extension ResourceDescription : CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable  {
    
    var description: String {
        return description(indent: 0)
    }
    
    var debugDescription: String {
        return description(indent: 0)
    }
    
    func description(indent: Int, indentFirst: Bool = true) -> String {
        
        var description = "\(String(repeating: "\t", count: indentFirst ? indent : 0))resource: {"
    
        description.append("\r\(String(repeating: "\t", count: indent + 1))path: '\(path)'")
        
        for parameter in self.parameters {
            description.append("\r\(parameter.description(indent: indent + 1))")
        }
        
        for operation in self.operations {
            description.append("\r\(operation.description(indent: indent + 1))")
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}
