//
//  ConnectEntity3Unmanaged+CoreDataProperties.swift
//  Coherence
//
//  Created by Tony Stone on 2/12/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension ConnectEntity3Unmanaged {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConnectEntity3Unmanaged> {
        return NSFetchRequest<ConnectEntity3Unmanaged>(entityName: "ConnectEntity3Unmanaged");
    }

    @NSManaged public var id: Int64

}
