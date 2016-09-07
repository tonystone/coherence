//
//  WADLResource.swift
//  Pods
//
//  Created by Tony Stone on 8/26/16.
//
//

import Swift


/**
    WADL Resource Element
 
    - Seealso: 
 
        [Web Application Description Language, 2.6 Resource](https://www.w3.org/Submission/wadl/#x3-120002.6)
 
 
<xs:element name="resource">
    <xs:complexType>
      <xs:sequence>
        <xs:element ref="tns:doc" minOccurs="0" maxOccurs="unbounded"/>
        <xs:element ref="tns:param" minOccurs="0" maxOccurs="unbounded"/>
        <xs:choice minOccurs="0" maxOccurs="unbounded">
          <xs:element ref="tns:method"/>
          <xs:element ref="tns:resource"/>
        </xs:choice>
        <xs:any minOccurs="0" maxOccurs="unbounded" namespace="##other"
          processContents="lax"/>
      </xs:sequence>
      <xs:attribute name="id" type="xs:ID"/>
      <xs:attribute name="type" type="tns:resource_type_list"/>
      <xs:attribute name="queryType" type="xs:string"
        default="application/x-www-form-urlencoded"/>
      <xs:attribute name="path" type="xs:string"/>
      <xs:anyAttribute namespace="##other" processContents="lax"/>
    </xs:complexType>
  </xs:element>
 */

class WADLResource : WADLElement {
    
    init(id: String?, path: String?, type: String?, queryType: WADLQueryType?, parent: WADLElement?) {
        self.id = id
        self.path = path
        self.type = type
        self.queryType = queryType ?? .applicationFormURLEncoded
        self.parent = parent
    }
    
    // Attributes
    let id: String?
    let path: String?
    let type: String?
    let queryType: WADLQueryType
    
    var otherAttributes: [String : String] = [:]
    
    // Elements
    var docs: [WADLDoc]             = []
    var params: [WADLParam]         = []
    var methods: [WADLMethod]       = []
    var resources: [WADLResource]   = []
    
    var otherElements: [XMLElement] = []
    
    weak var parent: WADLElement?
}

extension WADLResource : IndentedStringConvertable {
    
    func description(indent indent: Int) -> String {
        
        var description = "\(String(repeating: "\t", count: indent))resource: {"
        
        var first = true
        
        if let id = self.id {
            description.append("\(first ? "\r" + String(repeating: "\t", count: indent + 1) : ", ")id: \'\(id)\'")
            first = false
        }
        
        if let path = self.path {
            description.append("\(first ? "\r" + String(repeating: "\t", count: indent + 1) : ", ")path: \'\(path)\'")
            first = false
        }
        
        if let type = self.type {
            description.append("\(first ? "\r" + String(repeating: "\t", count: indent + 1) : ", ")type: \'\(type)\'")
            first = false
        }
        
        description.append("\(first ? "\r" + String(repeating: "\t", count: indent + 1) : ", ")queryType: \'\(self.queryType.rawValue)\'")
        first = false
        
        for param in self.params {
            description.append("\r\(param.description(indent: indent + 1))")
        }
        
        for method in self.methods {
            description.append("\r\(method.description(indent: indent + 1))")
        }
        
        for resource in self.resources {
            description.append("\r\(resource.description(indent: indent + 1))")
        }
        
        description.append("\r\(String(repeating: "\t", count: indent))}")
        
        return description
    }
}

extension WADLResource : CustomStringConvertible, CustomDebugStringConvertible {
    
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

extension WADLResource {
    
    var templatedURI: String {
        
        // http://www.w3.org/Submission/wadl/#x3-38000C
        //
        // The URI for a resource element is obtained using the following rules:
        //
        // (1) Set identifier equal to the URI computed (using this process) for the parent element (resource or resources)
        // (2) If identifier doesn't end with a '/' then append a '/' character to identifier
        // (3) Substitute the values of any URI template parameters into the value of the path attribute
        // (4) Append the value obtained in the previous step to identifier
        // (5) For each child param element (see section 2.12), in document order, that has a value of 'matrix' for its style attribute, append a representation of the parameter value to identifier according to the following rules:
        //      * Non-boolean matrix parameters are represented as: ';' name '=' value
        //      * Boolean matrix parameters are represented as: ';' name when value is true and are omitted from identifier when value is false
        //        where name is the value of the param element's name attribute and value is the runtime value of the parameter.
        
        var uri: String = ""
        
        // (1)
        if let parent = self.parent as? WADLResources {

            uri = parent.base.absoluteString
            
        } else if let parent = self.parent as? WADLResource {
            
            uri = parent.templatedURI
        }
        
        // (2)
        if !uri.hasSuffix("/") {
            uri.append("/")
        }
        
        // (3)
        if var substitutedPath = self.path  {    // Need to substitute the fixed params at this point
            
            for param in self.params {
                if param.style == .template, let value = param.fixed {
                    substitutedPath.replacingOccurrences(of: "{\(param.name)}", with: value)
                }
            }
            
            // (4)
            if substitutedPath.hasPrefix("/") { // this path may contain the / at the beginning
                substitutedPath.removeSubrange(substitutedPath.startIndex...substitutedPath.startIndex)
            }
            
            // (5) -  Append the matrix params
            for param in self.params {
                if param.style == .matrix, let value = param.fixed {
                    
                    if let type = param.type, type.hasSuffix("boolean") {   // xsd:boolean
                        
                        substitutedPath.append(";\(param.name)=\(value)")
                    } else {
                        if value == "true" {
                            substitutedPath.append(";\(param.name)")
                        }
                    }
                }
            }
            uri = uri + substitutedPath
        }
        return uri
    }
    
     var url: URL? {

        // http://www.w3.org/Submission/wadl/#x3-38000C
        //
        // The URI for a resource element is obtained using the following rules:
        //
        // (1) Set identifier equal to the URI computed (using this process) for the parent element (resource or resources)
        // (2) If identifier doesn't end with a '/' then append a '/' character to identifier
        // (3) Substitute the values of any URI template parameters into the value of the path attribute
        // (4) Append the value obtained in the previous step to identifier
        // (5) For each child param element (see section 2.12), in document order, that has a value of 'matrix' for its style attribute, append a representation of the parameter value to identifier according to the following rules:
        //      * Non-boolean matrix parameters are represented as: ';' name '=' value
        //      * Boolean matrix parameters are represented as: ';' name when value is true and are omitted from identifier when value is false 
        //        where name is the value of the param element's name attribute and value is the runtime value of the parameter.
    
        var relativeURL = URLComponents()
        
        // (1)
        if let parent = self.parent as? WADLResources,
           let url = URLComponents(url: parent.base, resolvingAgainstBaseURL: false) {
    
            relativeURL = url
        } else if let parent = self.parent as? WADLResource {
            if let parentURL = parent.url, let url = URLComponents(url: parentURL, resolvingAgainstBaseURL: false)  {
                relativeURL = url
            }
        }
        
        var parentPath = relativeURL.path
        
        // (2)
        if !parentPath.hasSuffix("/") {
            parentPath.append("/")
        }

        // (3)
        if var substitutedPath = self.path  {    // Need to substitute the fixed params at this point
        
            for param in self.params {
                if param.style == .template, let value = param.fixed {
                    substitutedPath.replacingOccurrences(of: "{\(param.name)}", with: value)
                }
            }
            
            // (4)
            if substitutedPath.hasPrefix("/") { // this path may contain the / at the beginning
                substitutedPath.removeSubrange(substitutedPath.startIndex...substitutedPath.startIndex)
            }

            // (5) -  Append the matrix params
            for param in self.params {
                if param.style == .matrix, let value = param.fixed {
                    
                    if let type = param.type, type.hasSuffix("boolean") {   // xsd:boolean
                        
                        substitutedPath.append(";\(param.name)=\(value)")
                    } else {
                        if value == "true" {
                            substitutedPath.append(";\(param.name)")
                        }
                    }
                }
            }
            relativeURL.path = parentPath + substitutedPath
        }
        
        var queryItems: [URLQueryItem] = []
        
        // Get the exisitng query params
        if let existingItems = relativeURL.queryItems {
            queryItems.append(contentsOf: existingItems)
        }
        
        for param in self.params {
            if param.style == .query {
                if let value = param.fixed  {
                    queryItems.append(URLQueryItem(name: param.name, value: value))
                } else {
                    if let defaultValue = param.defaultValue {
                        queryItems.append(URLQueryItem(name: param.name, value: defaultValue))
                    } else {
                        queryItems.append(URLQueryItem(name: param.name, value: "{\(param.name)}"))
                    }
                }
            }
        }
    
        if queryItems.count > 0 {
            relativeURL.queryItems = queryItems
        }
        return relativeURL.url
    }
}
