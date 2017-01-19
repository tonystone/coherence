//
//  WADLElement.swift
//  Pods
//
//  Created by Tony Stone on 8/30/16.
//
//

import Swift

protocol WADLElement : class {
    
    weak var parent: WADLElement? { get }
}
