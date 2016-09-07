//
//  Application.swift
//  Pods
//
//  Created by Tony Stone on 8/26/16.
//
//

import Swift

/**
    WADL Application Element
 
    - Seealso: 
 
        [Web Application Description Language, 2.2 Application](https://www.w3.org/Submission/wadl/#x3-70002.2)
 */
class WADLApplication : WADLElement {
    
    // Elements
    var docs: [WADLDoc]                         = []
    var grammars: WADLGrammars?                 = nil
    var resources: [WADLResources]              = []
    var resourceTypes: [WADLResourceType]       = []
    var methods: [WADLMethod]                   = []
    var representations: [WADLRepresentation]   = []
    var params: [WADLParam]                     = []
    
    var otherElements: [XMLElement]             = []
    
    // The parent of this application Element is always nil because Application has no parent in our model.
    weak var parent: WADLElement?               = nil
}
