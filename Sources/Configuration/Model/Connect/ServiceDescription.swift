//
//  ServiceDescription.swift
//  Pods
//
//  Created by Tony Stone on 9/12/16.
//
//

import Swift

///
/// A description of a web service
///
class ServiceDescription : ConfigurationElement {
    
    ///
    /// This is the required constructor to construct a complete ServiceDescription 
    ///
    required init(schemes: [Scheme], host: String, basePath: String?, resources: [ResourceDescription]) {
        self.schemes   = schemes
        self.host      = host
        self.basePath  = basePath
        self._resources = []
        
        for resource in resources {
            resource.service = self
        
            self._resources.append(resource)
        }
    }

    var id: String {
        return "\(self.host)\(self.basePath ?? "")"
    }
    let schemes: [Scheme]
    let host: String
    let basePath: String?
    
    ///
    /// All resources described by this ServiceDescription
    ///
    var resources: [ResourceDescription] {
        return _resources
    }
    private var _resources: [ResourceDescription]
}

///
/// Custom String Printing
///
extension ServiceDescription : CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable  {
    
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
        
        var description = "\(String(repeating: "\t", count: indentFirst ? indent : 0))service: {"
        
        description.append("\r\(String(repeating: "\t", count: indent + 1))host: '\(host)', '\(basePath ?? "")', schemes: '\(schemes)'")
        
        for resource in self.resources {
            description.append("\r\(resource.description(indent: indent + 1))")
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}
