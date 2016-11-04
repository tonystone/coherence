//
//  Configuration.swift
//  Pods
//
//  Created by Tony Stone on 9/12/16.
//
//

import Swift

class Configuration : ConfigurationElement {
    
    ///
    /// Construction of a complete Configuration is required
    ///
    init(name: String, version: String, services: [ServiceDescription]) {
        self.name = name
        self.version = version
        self.services = services
    }
    
    var id: String {
        return "\(self.name) (\(self.version))"
    }
    let name: String
    let version: String
    
    ///
    /// All resources described by this description
    ///
    let services: [ServiceDescription]
}

///
/// Custom String Printing
///
extension Configuration : CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable  {
    
    var description: String {
        get {
            return description(indent: 0)
        }
    }
    
    var debugDescription: String {
        get {
            return description(indent: 0)
        }
    }
    
    func description(indent indent: Int, indentFirst: Bool = true) -> String {
        
        var description = "\(String(repeating: "\t", count: indentFirst ? indent : 0))configuration: {"
        
        description.append("\r\(String(repeating: "\t", count: indent + 1))name: '\(self.name)', version: '\(self.version)'")
        
        for service in self.services {
            description.append("\r\(service.description(indent: indent + 1))")
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}
