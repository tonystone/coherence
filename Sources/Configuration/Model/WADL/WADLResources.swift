//
//  WADLResources.swift
//  Pods
//
//  Created by Tony Stone on 8/26/16.
//
//

import Swift

/**
    WADL Resources Element
 
    - seealso:
       
        [Web Application Description Language, 2.5 Resources](https://www.w3.org/Submission/wadl/#x3-110002.5)
 
 */
class WADLResources : WADLElement {
    
    init(base: URL, parent: WADLElement?) {
        self.base = base
        self.parent = parent
    }
    
    // Attributes
    let base: URL
    
    var otherAttributes: [String : String] = [:]
    
    // Elements
    var docs: [WADLDoc]             = []
    var resources: [WADLResource]   = []

    var otherElements: [XMLElement] = []
    
    weak var parent: WADLElement?
}

extension WADLResources : CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable {
    
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
        
        var description = "\(String(repeating: "\t", count: indent))resources: {"
        
        description.append("\r\(String(repeating: "\t", count: indent + 1))base: \'\(base.description)\'")
        
        for doc in self.docs {
            description.append("\r\(doc.description(indent: indent + 1))")
        }
        
        for resource in self.resources {
            description.append("\r\(resource.description(indent: indent + 1))")
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}

