//
//  ConnectEntity1+CoreDataProperties.swift
//  Coherence
//
//  Created by Tony Stone on 1/30/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import Foundation
import CoreData


extension ConnectEntity1 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConnectEntity1> {
        return NSFetchRequest<ConnectEntity1>(entityName: "ConnectEntity1");
    }

    @NSManaged public var binaryAttribute: NSData?
    @NSManaged public var boolAttribute: Bool
    @NSManaged public var id: Int64
    @NSManaged public var stringAttribute: String?
    @NSManaged public var transformableAttribute: NSObject?

}
