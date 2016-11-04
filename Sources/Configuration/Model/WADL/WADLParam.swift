//
//  WADLParam.swift
//  Pods
//
//  Created by Tony Stone on 8/27/16.
//
//

import Swift

/**
    WADL Param Element
 
    A param definition element describes a parameterized component of its parent element and may be a child of a resource (see section 2.6 ), application (see section 2.2 ), request (see section 2.9 ), response (see section 2.10 ), or a representation (see section 2.11 ) element. A param definition element has zero or more doc child elements (see section 2.3 ), zero or more option child elements (see section 2.12.3 ), an optional link child element (see section 2.12.4 ) and has the following attributes:

    id
        An optional identifier that may be used to refer to a parameter definition using a URI reference.
    name
        The name of the parameter as an xsd:NMTOKEN. Required.
    style
        Indicates the parameter style, table 1 on page 25 lists the allowed values and shows the context(s) in which each value may be used.
    type
        Optionally indicates the type of the parameter as an XML qualified name, defaults to xsd:string.
    default
        Optionally provides a value that is considered identical to an unspecified parameter value.
    path
        When the parent element is a representation element, this attribute optionally provides a path to the value of the parameter within the representation. For XML representations, use of XPath 1.0[4] is recommended.
    required
        Optionally indicates whether the parameter is required to be present or not, defaults to false (parameter not required).
    repeating
        Optionally indicates whether the parameter is single valued or may have multiple values, defaults to false (parameter is single valued).
    fixed
        Optionally provides a fixed value for the parameter.
 
    Note that some combinations of the above attributes might not make sense in all cases. E.g. matrix URI parameters are normally optional so a param element with a style value of 'matrix' and a required value of 'true' might be unwise.
 
    - Seealso:
 
        [Web Application Description Language, 2.8.2 Method Reference](https://www.w3.org/Submission/wadl/#x3-90002.8.2)
 */
class WADLParam : WADLElement  {
    
    enum Style : String {
        case matrix
        case header
        case query
        case template
        case plain
    }
    
    init(name: String, style: Style, id: String?, type: String?, defaultValue: String?, path: String?, required: Bool = false, repeating: Bool = false, fixed: String?, parent: WADLElement?) {
        self.id = id
        self.name = name
        self.style = style
        self.type = type
        self.defaultValue = defaultValue
        self.path = path
        self.required = required
        self.repeating = repeating
        self.fixed = fixed
        self.parent = parent
    }

    // Attributes
    let id: String?
    let name: String
    let style: Style
    let type: String?
    let defaultValue: String?
    let path: String?
    let required: Bool  // false
    let repeating: Bool // false
    let fixed: String?
    
    var otherAttributes: [String : String] = [:]
    
    // Elements
    var docs: [WADLDoc]       = []
    var options: [WADLOption] = []
    var links: [WADLLink]     = []
    
    var otherElements: [XMLElement] = []
    
    weak var parent: WADLElement?
}

///
/// Custom String Printing
///
extension WADLParam : CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable {
    
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
     
        var description = "\(String(repeating: "\t", count: indent))param: {"
        
        description.append("\r\(String(repeating: "\t", count: indent + 1))name: \'\(self.name)\', style: \'\(self.style)\', required: \(self.required), repeating: \(self.repeating)")
        
        if let id = self.id {
            description.append(", id: \'\(id)\'")
        }
        
        if let type = self.type {
            description.append(", type: \'\(type)\'")
        }
        
        if let path = self.path {
            description.append(", path: \'\(path)\'")
        }
        
        if let fixed = self.fixed {
            description.append(", fixed: \'\(fixed)\'")
        }
        
        if let defaultValue = self.defaultValue {
            description.append(", defaultValue: \'\(defaultValue)\'")
        }
        
        for doc in self.docs {
            description.append("\r\(doc.description(indent: indent + 1))")
        }
        
        for option in self.options {
            description.append("\r\(option.description(indent: indent + 1))")
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}
