//
//  Executable+CoreDataProperties.swift
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

extension Executable {

    @NSManaged var script: String?
    @NSManaged var phase: String?
    @NSManaged var recipe: String?
    @NSManaged var position: Int32
    @NSManaged var scriptReference: String?
    @NSManaged var parentReference: String?

}
