//
//  WADLDoc.swift
//  Pods
//
//  Created by Tony Stone on 8/27/16.
//
//

import Swift

///
/// Each WADL-defined element can have one or more child doc elements that can be used to document that element. The doc element has the following attributes:
///
///     * xml:lang - Defines the language for the title attribute value and the contents of the doc element. If an element contains more than one doc element then they MUST have distinct values for their xml:lang attribute.
///
///     * title - A short plain text description of the element being documented, the value SHOULD be suitable for use as a title for the contained documentation.
///
/// The doc element has mixed content and may contain text and zero or more child elements that form the body of the documentation. It is RECOMMENDED that the child elements be members of the text, list or table modules of XHTML[2].
///
class WADLDoc : WADLElement  {
    
    init(lang: String, title: String, text: String?, parent: WADLElement?) {
        self.lang = lang
        self.title = title
        self.text = text
        self.parent = parent
        self.otherElements = [AnyObject]()
    }
    
    let lang: String
    let title: String
    
    let text: String?
    var otherElements: [AnyObject]
    
    weak var parent: WADLElement?
}

///
/// Custom String Printing
///
extension WADLDoc : CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable {
    
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
        
        var description = "\(String(repeating: "\t", count: indent))doc: {"
        
        description.append("\r\(String(repeating: "\t", count: indent + 1))lang: \'\(self.lang)\', title: \'\(self.title)\'")
        
        if let text = self.text {
            description.append("\r\(String(repeating: "\t", count: indent + 1))text: \'\(text)\'")
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}

