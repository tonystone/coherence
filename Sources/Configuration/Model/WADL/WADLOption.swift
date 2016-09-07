//
//  WADLOption.swift
//  Pods
//
//  Created by Tony Stone on 8/27/16.
//
//

import Swift

class WADLOption : WADLElement  {
    
    init(parent: WADLElement?) {
        self.parent = parent
    }
    
    weak var parent: WADLElement?
}
