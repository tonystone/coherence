//
//  Resource+CoreDataProperties.swift
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

extension Resource {

    @NSManaged var providerProperties: NSObject?
    @NSManaged var providerPrivateData: NSObject?
    @NSManaged var resourceReference: String?
    @NSManaged var resourceReferenceLink: NSObject?
    @NSManaged var textDescription: String?
    @NSManaged var name: String?

}
