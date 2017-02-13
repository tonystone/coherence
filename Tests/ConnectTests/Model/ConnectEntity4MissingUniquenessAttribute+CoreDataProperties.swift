//
//  ConnectEntity4MissingUniquenessAttribute+CoreDataProperties.swift
//  Coherence
//
//  Created by Tony Stone on 2/12/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import Foundation
import CoreData


extension ConnectEntity4MissingUniquenessAttribute {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConnectEntity4MissingUniquenessAttribute> {
        return NSFetchRequest<ConnectEntity4MissingUniquenessAttribute>(entityName: "ConnectEntity4MissingUniquenessAttribute");
    }

    @NSManaged public var id: Int64

}
