//
//  WADLLink.swift
//  Pods
//
//  Created by Tony Stone on 8/27/16.
//
//

import Swift

class WADLLink : WADLElement  {

    init(parent: WADLElement?) {
        self.parent = parent
    }
    
    weak var parent: WADLElement?
}

