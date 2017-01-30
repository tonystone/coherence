//
//  Job+CoreDataProperties.swift
//  Coherence
//
//  Created by Tony Stone on 1/30/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import Foundation
import CoreData


extension Job {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Job> {
        return NSFetchRequest<Job>(entityName: "Job");
    }

    @NSManaged public var maxSalary: NSDecimalNumber?
    @NSManaged public var minSalary: NSDecimalNumber?
    @NSManaged public var title: String?

}
