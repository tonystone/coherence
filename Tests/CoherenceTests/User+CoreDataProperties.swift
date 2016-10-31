//
//  User+CoreDataProperties.swift
//  
//
//  Created by Tony Stone on 1/6/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

public extension User {

    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var userName: String?

}
