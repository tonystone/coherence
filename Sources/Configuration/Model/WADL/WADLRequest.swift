//
//  WADLRequest.swift
//  Pods
//
//  Created by Tony Stone on 8/27/16.
//
//

import Swift

/**
    WADL Request Element
 
    - Seealso:
 
        [Web Application Description Language, 2.9 Request](https://www.w3.org/Submission/wadl/#x3-90002.9)
 */
class WADLRequest : WADLElement  {
    
    init(parent: WADLElement?) {
        self.parent = parent
    }
    
    // Attributes
    var otherAttributes: [String : String]      = [:]
    
    // Elements
    var docs: [WADLDoc]                         = []
    var params: [WADLParam]                     = []
    var representations: [WADLRepresentation]   = []
    
    var otherElements: [XMLElement]             = []
    
    weak var parent: WADLElement?
    
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
}

extension WADLRequest : IndentedStringConvertable {
    
    func description(indent indent: Int) -> String {
        
        var description = "\(String(repeating: "\t", count: indent))request: {"
        
        for param in self.params {
            description.append("\r\(param.description(indent: indent + 1))")
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}
