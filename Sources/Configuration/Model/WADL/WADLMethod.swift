//
//  WADLMethod.swift
//  Pods
//
//  Created by Tony Stone on 8/27/16.
//
//

import Swift

/**
    WADL Response Element
 
    - Seealso:
 
        [Web Application Description Language, 2.8 Method](https://www.w3.org/Submission/wadl/#x3-90002.8)
 */
class WADLMethod : WADLElement  {
    
    init(name: String, id: String?, parent: WADLElement?) {
        self.name = name
        self.id   = id
        self.href = nil
        self.parent = parent
    }
    init(href: URL, parent: WADLElement?) {
        self.href = href
        self.id   = nil
        self.name = nil
        self.parent = parent
    }
    
    // Attributes
    let href: URL?
    let name: String?
    let id: String?
    
    var otherAttributes: [String : String]      = [:]
    
    // Elements
    var docs: [WADLDoc]                         = []
    var request: WADLRequest?                   = nil
    var responses: [WADLResponse]               = []
    
    var otherElements: [XMLElement]             = []
    
    weak var parent: WADLElement?
    
    var description: String {
        get {
            return self.description(indent: 0)
        }
    }
    
    var debugDescription: String {
        get {
            return self.description(indent: 0)
        }
    }
}

extension WADLMethod : IndentedStringConvertable {

    func description(indent indent: Int) -> String {
        
        var description = "\(String(repeating: "\t", count: indent))method: {"
        
        var first = true
        
        if let id = self.id {
            description.append("\(first ? "\r" + String(repeating: "\t", count: indent + 1) : ", ")id: \'\(id)\'")
            first = false
        }
        
        if let name = self.name {
            description.append("\(first ? "\r" + String(repeating: "\t", count: indent + 1) : ", ")name: \'\(name)\'")
            first = false
        }
        
        if let request = self.request {
            description.append("\r\(request.description(indent: indent + 1))")
            first = false
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}
