//
//  InstanceType+CoreDataProperties.swift
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

extension InstanceType {

    @NSManaged var cloudReference: String?
    @NSManaged var memory: String?
    @NSManaged var cpuArchitecture: String?
    @NSManaged var cpuCount: String?
    @NSManaged var cpuSpeed: String?
    @NSManaged var localDisks: String?
    @NSManaged var localDiskSize: String?
    @NSManaged var resourceUid: String?

}
