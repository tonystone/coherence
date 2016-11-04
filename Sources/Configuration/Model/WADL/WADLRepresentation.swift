//
//  WADLRepresentation.swift
//  Pods
//
//  Created by Tony Stone on 8/27/16.
//
//

import Swift

///
///    WADL Request Element
///
///    - Seealso:
///
///        [Web Application Description Language, 2.11 Representation](https://www.w3.org/Submission/wadl/#x3-90002.11)
///
class WADLRepresentation : WADLElement  {
    
    init(mediaType: WADLMediaType, id: String?, element: String?, profile: String?, parent: WADLElement?) {
        self.mediaType = mediaType
        self.id = id
        self.element = element
        self.profile = profile
        self.parent = parent
    }
    
    /// Attributes
    let mediaType: WADLMediaType
    
    let id: String?
    let element: String?
    let profile: String?
    
    var otherAttributes: [String : String]      = [:]
    
    /// Elements
    var docs: [WADLDoc]                         = []
    var params: [WADLParam]                     = []
    
    var otherElements: [XMLElement]             = []
    
    weak var parent: WADLElement?
}

///
/// Custom String Printing
///
extension WADLRepresentation : CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable {
    
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
        
        var description = "\(String(repeating: "\t", count: indent))representation: {"
        
        description.append("\r\(String(repeating: "\t", count: indent + 1))mediaType: \'\(mediaType.rawValue)\'")
        
        var first = true
        
        if let id = self.id {
            description.append("\(first ? "\r" + String(repeating: "\t", count: indent + 1) : ", ")id: \'\(id)\'")
            first = false
        }
        
        if let element = self.element {
            description.append("\(first ? "\r" + String(repeating: "\t", count: indent + 1) : ", ")element: \'\(element)\'")
            first = false
        }
        
        if let profile = self.profile {
            description.append("\(first ? "\r" + String(repeating: "\t", count: indent + 1) : ", ")profile: \'\(profile)\'")
            first = false
        }
        
        for doc in self.docs {
            description.append("\r\(doc.description(indent: indent + 1))")
        }
        
        for param in self.params {
            description.append("\r\(param.description(indent: indent + 1))")
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}
