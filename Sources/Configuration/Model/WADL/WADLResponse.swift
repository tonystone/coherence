//
//  WADLResponse.swift
//  Pods
//
//  Created by Tony Stone on 8/27/16.
//
//

import Swift

/**
    WADL Response Element
 
    - Seealso:
 
        [Web Application Description Language, 2.10 Response](https://www.w3.org/Submission/wadl/#x3-90002.10)
 */
class WADLResponse : WADLElement  {
    
    init(status: String?, parent: WADLElement?) {
        self.status = status
        self.parent = parent
    }

    // Attributes
    let status: String?
    var otherAttributes: [String : String]      = [:]
    
    // Elements
    var docs: [WADLDoc]                         = []
    var representations: [WADLRepresentation]   = []
    var params: [WADLParam]                     = []
    
    var otherElements: [XMLElement]             = []
    
    weak var parent: WADLElement?
}
