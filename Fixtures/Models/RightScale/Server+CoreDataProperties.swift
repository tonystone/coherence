//
//  Server+CoreDataProperties.swift
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

extension Server {

    @NSManaged var currentInstanceReference: String?
    @NSManaged var nextInstanceReference: String?
    @NSManaged var serverTemplateReference: String?
    @NSManaged var state: Int32
    @NSManaged var stateSection: Int32

}
