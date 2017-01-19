//
//  WADLGrammars.swift
//  Pods
//
//  Created by Tony Stone on 8/27/16.
//
//

import Swift

/**
    WADL Grammers Element
 
    - Seealso: 
 
        [Web Application Description Language, 2.4 Grammers](https://www.w3.org/Submission/wadl/#x3-90002.4)
 */
class WADLGrammars : WADLElement  {
    
    init(parent: WADLElement?) {
        self.parent = parent
    }
    
    weak var parent: WADLElement?
}

///
/// Custom String Printing
///
extension WADLGrammars : CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable {
    
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
        
        var description = "\(String(repeating: "\t", count: indent))grammers: {"
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}
