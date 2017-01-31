//
//  JobHistory+CoreDataProperties.swift
//  Coherence
//
//  Created by Tony Stone on 1/30/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import Foundation
import CoreData


extension JobHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<JobHistory> {
        return NSFetchRequest<JobHistory>(entityName: "JobHistory");
    }

    @NSManaged public var endDate: NSDate?
    @NSManaged public var startDate: NSDate?
    @NSManaged public var department: Department?
    @NSManaged public var employee: Employee?
    @NSManaged public var job: Job?

}
