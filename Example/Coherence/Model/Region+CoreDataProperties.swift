//
//  Region+CoreDataProperties.swift
//  Coherence
//
//  Created by Tony Stone on 1/30/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import Foundation
import CoreData


extension Region {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Region> {
        return NSFetchRequest<Region>(entityName: "Region");
    }

    @NSManaged public var name: String?

}
