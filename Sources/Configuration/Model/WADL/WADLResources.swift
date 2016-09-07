//
//  WADLResources.swift
//  Pods
//
//  Created by Tony Stone on 8/26/16.
//
//

import Swift

/**
    WADL Resources Element
 
    - seealso:
       
        [Web Application Description Language, 2.5 Resources](https://www.w3.org/Submission/wadl/#x3-110002.5)
 
 */
class WADLResources : WADLElement {
    
    init(base: URI, parent: WADLElement?) {
        self.base = base
        self.parent = parent
    }
    
    // Attributes
    let base: URI
    
    var otherAttributes: [String : String] = [:]
    
    // Elements
    var docs: [WADLDoc]             = []
    var resources: [WADLResource]   = []

    var otherElements: [XMLElement] = []
    
    weak var parent: WADLElement?
}
