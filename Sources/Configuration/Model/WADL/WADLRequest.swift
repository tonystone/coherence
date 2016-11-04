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
}

///
/// Custom String Printing
///
extension WADLRequest : CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable {
    
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
        
        var description = "\(String(repeating: "\t", count: indent))request: {"
        
        for doc in self.docs {
            description.append("\r\(doc.description(indent: indent + 1))")
        }
        
        for param in self.params {
            description.append("\r\(param.description(indent: indent + 1))")
        }
        
        for representation in self.representations {
            description.append("\r\(representation.description(indent: indent + 1))")
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}
