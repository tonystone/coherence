//
//  WADLRepresentation.swift
//  Pods
//
//  Created by Tony Stone on 8/27/16.
//
//

import Swift

/**
    WADL Request Element
 
    - Seealso:
 
        [Web Application Description Language, 2.11 Representation](https://www.w3.org/Submission/wadl/#x3-90002.11)
 */
class WADLRepresentation : WADLElement  {
    
    init(mediaType: String, id: String?, element: String?, profile: String?, parent: WADLElement?) {
        self.mediaType = mediaType
        self.id = id
        self.element = element
        self.profile = profile
        self.parent = parent
    }
    
    // Attributes
    let mediaType: String
    
    let id: String?
    let element: String?
    let profile: String?
    
    var otherAttributes: [String : String]      = [:]
    
    // Elements
    var docs: [WADLDoc]                         = []
    var params: [WADLParam]                     = []
    
    var otherElements: [XMLElement]             = []
    
    weak var parent: WADLElement?
}
