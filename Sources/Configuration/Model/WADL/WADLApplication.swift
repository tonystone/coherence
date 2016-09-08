//
//  Application.swift
//  Pods
//
//  Created by Tony Stone on 8/26/16.
//
//

import Swift

/**
    WADL Application Element
 
    - Seealso: 
 
        [Web Application Description Language, 2.2 Application](https://www.w3.org/Submission/wadl/#x3-70002.2)
 */
class WADLApplication : WADLElement {
    
    init(parent: WADLElement?) {
        self.parent = parent
    }
    
    // Elements
    var docs: [WADLDoc]                         = []
    var grammars: WADLGrammars?                 = nil
    var resources: [WADLResources]              = []
    var resourceTypes: [WADLResourceType]       = []
    var methods: [WADLMethod]                   = []
    var representations: [WADLRepresentation]   = []
    var params: [WADLParam]                     = []
    
    var otherElements: [XMLElement]             = []
    
    weak var parent: WADLElement?
}

extension WADLApplication : CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable  {
    
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
    
    func description(indent indent: Int) -> String {
        
        var description = "\(String(repeating: "\t", count: indent))application: {"
        
        for doc in self.docs {
            description.append("\r\(doc.description(indent: indent + 1))")
        }
        
        if let grammers = self.grammars {
            description.append("\r\(grammers.description(indent: indent + 1))")
        }
        
        for resources in self.resources {
            description.append("\r\(resources.description(indent: indent + 1))")
        }
        
        for resourceType in self.resourceTypes {
            description.append("\r\(resourceType.description(indent: indent + 1))")
        }
        
        for method in self.methods {
            description.append("\r\(method.description(indent: indent + 1))")
        }
        
        for representation in self.representations {
            description.append("\r\(representation.description(indent: indent + 1))")
        }
        
        for param in self.params {
            description.append("\r\(param.description(indent: indent + 1))")
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}

