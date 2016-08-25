//
//  ServerArray+CoreDataProperties.swift
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

extension ServerArray {

    @NSManaged var arrayType: String?
    @NSManaged var instanceCount: Int32
    @NSManaged var enabled: Bool
    @NSManaged var nextInstanceReference: String?
    @NSManaged var serverTemplateReference: String?
    @NSManaged var currentInstancesReference: String?

}
