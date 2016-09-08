//
//  HTMLMediaType.swift
//  Pods
//
//  Created by Tony Stone on 8/28/16.
//
//

import Foundation

struct WADLMediaType : CustomStringConvertible {
    
    static let multiPartFormData = WADLMediaType(rawValue: "multipart/form-data")
    static let applicationFormURLEncoded = WADLMediaType(rawValue: "application/x-www-form-urlencoded")
    static let applicationJSON = WADLMediaType(rawValue: "application/json")
    static let applicationXML = WADLMediaType(rawValue: "application/xml")
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
    let rawValue: String
    
    var description: String {
        get {
            return rawValue
        }
    }
}

//enum WADLMediaType: String {
//    case multiPartFormData         = "multipart/form-data"
//    case applicationFormURLEncoded = "application/x-www-form-urlencoded"
//    case applicationJSON           = "application/json"
//    case applicationXML            = "application/xml"
//    case custom
//}
