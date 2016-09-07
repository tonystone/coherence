//
//  MappingServiceDescription.swift
//  Pods
//
//  Created by Tony Stone on 8/25/16.
//
//

import Foundation


public protocol MappingServiceDescription {
    
    /**
     
     Key value pairs mapping API result set elements to CoreData model fields
     
     Example:
     
     Instances
     
     Key (CoreData)         Value (JSON Keypath)
     ---------------------- ----------------
     instanceID             id
     cloudID                cloud_id
     publicIPAddresses      public_ip_addresses
     privateIPAddresses     private_ip_addresses
     
     
     Subnets
     
     Key (CoreData)         Value (keyPath)
     ---------------------- ----------------
     
     name                   name
     visibility             visibility
     resourceUID            resource_uid
     description            description
     
     
     */
    var mapping: [String : String] { get }
    
    
    var mappingRoot: String { get }

    /**
     */
    var entityArrayKeyPath: String { get }

    /**
     
     */
    var urnPrefix: String { get }

    /**
     
     */
    var assignMissingValuesNull: Bool { get }

}