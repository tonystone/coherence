//
//  ConnectEntity2+CoreDataProperties.swift
//  Coherence
//
//  Created by Tony Stone on 1/30/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import Foundation
import CoreData


extension ConnectEntity2 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConnectEntity2> {
        return NSFetchRequest<ConnectEntity2>(entityName: "ConnectEntity2");
    }

    @NSManaged public var id: Int64
    @NSManaged public var stringAttribute: String?

}
