//
//  WADLResponse.swift
//  Pods
//
//  Created by Tony Stone on 8/27/16.
//
//

import Swift

/**
    WADL Response Element
 
    - Seealso:
 
        [Web Application Description Language, 2.10 Response](https://www.w3.org/Submission/wadl/#x3-90002.10)
 */
class WADLResponse : WADLElement  {
    
    init(status: String?, parent: WADLElement?) {
        self.status = status
        self.parent = parent
    }

    // Attributes
    let status: String?
    var otherAttributes: [String : String]      = [:]
    
    // Elements
    var docs: [WADLDoc]                         = []
    var representations: [WADLRepresentation]   = []
    var params: [WADLParam]                     = []
    
    var otherElements: [XMLElement]             = []
    
    weak var parent: WADLElement?
}

extension WADLResponse : CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable {
    
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
        
        var description = "\(String(repeating: "\t", count: indent))response: {"
        
        var first = true
        
        if let status = self.status {
            description.append("\(first ? "\r" + String(repeating: "\t", count: indent + 1) : ", ")status: \'\(status)\'")
            first = false
        }
        
        for doc in self.docs {
            description.append("\r\(doc.description(indent: indent + 1))")
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
