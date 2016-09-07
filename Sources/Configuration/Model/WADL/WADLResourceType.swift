//
//  WADLResourceType.swift
//  Pods
//
//  Created by Tony Stone on 8/27/16.
//
//

import Swift

class WADLResourceType : WADLElement  {
    
    init(id: String, parent: WADLElement?) {
        self.id   = id
        self.parent = parent
    }
    // Attributes
    let id: String
    
    var otherAttributes: [String : String] = [:]
    
    // Elements
    var docs: [WADLDoc]           = []
    var params: [WADLParam]       = []
    var methods: [WADLMethod]     = []
    var resources: [WADLResource] = []
    
    var otherElements: [XMLElement] = []
    
    weak var parent: WADLElement?
}
