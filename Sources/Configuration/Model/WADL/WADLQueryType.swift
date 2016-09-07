//
//  HTMLQueryType.swift
//  Pods
//
//  Created by Tony Stone on 8/28/16.
//
//

import Foundation

enum WADLQueryType : String {
    case multiPartFormData         = "multipart/form-data"
    case applicationFormURLEncoded = "application/x-www-form-urlencoded"
    case applicationJSON           = "application/json"
    case applicationXML            = "application/xml"
}