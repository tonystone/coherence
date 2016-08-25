//
//  VersionedResource+CoreDataProperties.swift
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

extension VersionedResource {

    @NSManaged var version: Double
    @NSManaged var isHeadRevision: Bool

}
