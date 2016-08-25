//
//  Instance+CoreDataProperties.swift
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

extension Instance {

    @NSManaged var monitoringMetricsReference: String?
    @NSManaged var multiCloudImageReference: String?
    @NSManaged var osPlatform: String?
    @NSManaged var serverTemplateReference: String?
    @NSManaged var terminatedAt: NSTimeInterval
    @NSManaged var volumeAttachmentsReference: String?
    @NSManaged var datacenterReference: String?
    @NSManaged var launchedAt: NSTimeInterval
    @NSManaged var userData: String?
    @NSManaged var state: Int32
    @NSManaged var instanceTypeReference: String?
    @NSManaged var parentReference: String?
    @NSManaged var pricingType: String?
    @NSManaged var cloudReference: String?
    @NSManaged var price: String?

}
