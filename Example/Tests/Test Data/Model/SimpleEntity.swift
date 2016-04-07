//
//  SimpleEntity.swift
//  Coherence
//
//  Created by Paul Chang on 4/6/16.
//  Copyright © 2016 Tony Stone. All rights reserved.
//

import Foundation
import CoreData

public class SimpleEntity: NSManagedObjectModel {
    
    @NSManaged var userId: NSNumber?
    @NSManaged var transactionId: String?
}