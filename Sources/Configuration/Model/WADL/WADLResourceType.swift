//
//  WADLResourceType.swift
//  Pods
//
//  Created by Tony Stone on 8/27/16.
//
//

import Swift

class WADLResourceType : WADLElement  {
    
    init(id: String, parent: WADLElement?) {
        self.id   = id
        self.parent = parent
    }
    // Attributes
    let id: String
    
    var otherAttributes: [String : String] = [:]
    
    // Elements
    var docs: [WADLDoc]           = []
    var params: [WADLParam]       = []
    var methods: [WADLMethod]     = []
    var resources: [WADLResource] = []
    
    var otherElements: [XMLElement] = []
    
    weak var parent: WADLElement?
}

///
/// Custom String Printing
///
extension WADLResourceType : CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable  {
    
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
        
        var description = "\(String(repeating: "\t", count: indent))resourceType: {"
        
        description.append("\r\(String(repeating: "\t", count: indent + 1))id: \'\(self.id)\'")
        
        for doc in self.docs {
            description.append("\r\(doc.description(indent: indent + 1))")
        }
        
        for param in self.params {
            description.append("\r\(param.description(indent: indent + 1))")
        }
        
        for method in self.methods {
            description.append("\r\(method.description(indent: indent + 1))")
        }
        
        for resource in self.resources {
            description.append("\r\(resource.description(indent: indent + 1))")
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}
