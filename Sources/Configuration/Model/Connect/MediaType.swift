//
//  MediaType.swift
//  Pods
//
//  Created by Tony Stone on 9/19/16.
//
//

import Swift

struct MediaType : CustomStringConvertible {
    
    static let multiPartFormData = MediaType(rawValue: "multipart/form-data")
    static let applicationFormURLEncoded = MediaType(rawValue: "application/x-www-form-urlencoded")
    static let applicationJSON = MediaType(rawValue: "application/json")
    static let applicationXML = MediaType(rawValue: "application/xml")
    
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
