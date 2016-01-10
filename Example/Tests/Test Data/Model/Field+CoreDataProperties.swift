//
//  Field+CoreDataProperties.swift
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

public extension Field {

    @NSManaged var area: NSObject?
    @NSManaged var farmId: String?
    @NSManaged var fieldId: String?
    @NSManaged var fieldUuid: String?
    @NSManaged var name: String?
    @NSManaged var version: Int32

}
