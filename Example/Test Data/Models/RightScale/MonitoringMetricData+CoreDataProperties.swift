//
//  MonitoringMetricData+CoreDataProperties.swift
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

extension MonitoringMetricData {

    @NSManaged var metricVariableData: NSObject?
    @NSManaged var start: NSTimeInterval
    @NSManaged var end: NSTimeInterval
    @NSManaged var monitoringMetricReference: String?

}
