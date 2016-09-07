//
//  Event+CoreDataProperties.swift
//  
//
//  Created by Tony Stone on 8/21/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Event {

    @NSManaged var parentName: String?
    @NSManaged var ignore: Bool
    @NSManaged var read: Bool
    @NSManaged var position: Int32
    @NSManaged var parentReference: String?

}
