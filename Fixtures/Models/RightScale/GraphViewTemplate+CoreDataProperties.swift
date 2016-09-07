//
//  GraphViewTemplate+CoreDataProperties.swift
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

extension GraphViewTemplate {

    @NSManaged var verticalLabel: String?
    @NSManaged var limitLower: NSDecimalNumber?
    @NSManaged var limitUpper: NSDecimalNumber?
    @NSManaged var autoGrid: Bool
    @NSManaged var logarithmicScaling: Bool
    @NSManaged var unitsDecimalPlaces: Int32
    @NSManaged var unitsBase: Int32
    @NSManaged var rigidBoundariesMode: Bool
    @NSManaged var unitsLength: Int32
    @NSManaged var baseValue: Int32
    @NSManaged var gridStep: Int32
    @NSManaged var plotLineColors: NSObject?
    @NSManaged var plotTitles: NSObject?
    @NSManaged var unitsExponent: Int32
    @NSManaged var autoScale: Bool

}
