//
//  ConnectEntity3Unmanaged+CoreDataClass.swift
//  Coherence
//
//  Created by Tony Stone on 2/12/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

@objc(ConnectEntity3Unmanaged)
public class ConnectEntity3Unmanaged: NSManagedObject {

    public enum Errors: Error {
        case entityNotFound(String)
    }

    internal class func newTestObjects(for context: NSManagedObjectContext, count: Int64) throws -> (entity: NSEntityDescription, objects: [ConnectEntity3Unmanaged]) {

        var objects: [ConnectEntity3Unmanaged] = []

        guard let entity = NSEntityDescription.entity(forEntityName: "ConnectEntity3Unmanaged", in: context) else {
            throw Errors.entityNotFound("Failed to find entity 'ConnectEntity3Unmanaged' in context")
        }

        for index in Int64(0)..<count {

            let object = ConnectEntity3Unmanaged(entity: entity, insertInto: nil)
            object.id = index

            objects.append(object)
        }
        return (entity, objects)
    }
}
