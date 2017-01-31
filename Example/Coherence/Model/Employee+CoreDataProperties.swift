//
//  Employee+CoreDataProperties.swift
//  Coherence
//
//  Created by Tony Stone on 1/30/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import Foundation
import CoreData


extension Employee {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Employee> {
        return NSFetchRequest<Employee>(entityName: "Employee");
    }

    @NSManaged public var commisionPercentage: NSDecimalNumber?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var hireDate: NSDate?
    @NSManaged public var lastName: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var salary: NSDecimalNumber?
    @NSManaged public var department: Department?
    @NSManaged public var job: Job?
    @NSManaged public var manager: Employee?

}
