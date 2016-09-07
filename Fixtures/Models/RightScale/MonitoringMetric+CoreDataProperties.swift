//
//  MonitoringMetric+CoreDataProperties.swift
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

extension MonitoringMetric {

    @NSManaged var userPosition: Int32
    @NSManaged var plugin: String?
    @NSManaged var period: String?
    @NSManaged var pluginType: String?
    @NSManaged var autoRefresh: Bool
    @NSManaged var graphImageReference: String?
    @NSManaged var defaultPosition: Int32
    @NSManaged var autoRefreshInterval: Int32
    @NSManaged var instanceReference: String?

}
