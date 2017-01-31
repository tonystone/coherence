//
//  Location+CoreDataProperties.swift
//  Coherence
//
//  Created by Tony Stone on 1/30/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location");
    }

    @NSManaged public var address: String?
    @NSManaged public var city: String?
    @NSManaged public var state: String?
    @NSManaged public var zip: String?
    @NSManaged public var country: Country?

}
