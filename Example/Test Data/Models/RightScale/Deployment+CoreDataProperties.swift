//
//  Deployment+CoreDataProperties.swift
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

extension Deployment {

    @NSManaged var inputsReference: String?
    @NSManaged var serversReference: String?
    @NSManaged var serverArraysReference: String?

}
