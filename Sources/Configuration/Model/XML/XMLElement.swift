//
//  XMLElement.swift
//  Pods
//
//  Created by Tony Stone on 8/26/16.
//
//

import Foundation

class XMLElement : XMLNode {
    
    init(name: String, qualifiedName: String?, namespaceURI: String?) {
        self.name = name
        self.qualifiedName = qualifiedName
        self.namespaceURI = namespaceURI
    }
    
    var name: String
    var qualifiedName: String?
    var namespaceURI: String?

    var namespaces = [String : String]()

}
