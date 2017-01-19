//
//  WADLOption.swift
//  Pods
//
//  Created by Tony Stone on 8/27/16.
//
//

import Swift

class WADLOption : WADLElement  {
    
    init(value: String, mediaType: WADLMediaType?, parent: WADLElement?) {
        self.value = value
        self.mediaType = mediaType
        self.parent = parent
    }
    
    let value: String
    let mediaType: WADLMediaType?
    
    weak var parent: WADLElement?
}

///
/// Custom String Printing
///
extension WADLOption : CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable {
    
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
    
    func description(indent: Int, indentFirst: Bool = true) -> String {
        
        var description = "\(String(repeating: "\t", count: indent))param: {"
        
        description.append("\r\(String(repeating: "\t", count: indent + 1))value: \'\(self.value)\'")
        
        if let mediaType = self.mediaType {
            description.append(", mediaType: \'\(mediaType)\'")
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}
