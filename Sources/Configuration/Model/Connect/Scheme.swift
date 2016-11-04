//
//  Scheme.swift
//  Pods
//
//  Created by Tony Stone on 9/13/16.
//
//

import Swift

enum Scheme: String, CustomStringConvertible {
    case http  = "http"
    case https = "https"
    case ws    = "ws"
    case wss   = "wss"
    
    var description: String {
        get { return self.rawValue }
    }
}
