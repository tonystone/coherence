///
///  ConnectEntity1+CoreDataClass.swift
///
///  Copyright 2017 Tony Stone
///
///  Licensed under the Apache License, Version 2.0 (the "License");
///  you may not use this file except in compliance with the License.
///  You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///  Unless required by applicable law or agreed to in writing, software
///  distributed under the License is distributed on an "AS IS" BASIS,
///  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///  See the License for the specific language governing permissions and
///  limitations under the License.
///
///  Created by Tony Stone on 1/30/17.
///
import Foundation
import CoreData

@objc(ConnectEntity1)
public class ConnectEntity1: NSManagedObject {

    public enum Errors: Error {
        case entityNotFound(String)
    }

    internal class func newTestObjects(for context: NSManagedObjectContext, count: Int64, boolValue: Bool, stringValue: String, dataValue: Data) throws -> (entity: NSEntityDescription, objects: [ConnectEntity1]) {

        var objects: [ConnectEntity1] = []

        guard let entity = NSEntityDescription.entity(forEntityName: "ConnectEntity1", in: context) else {
            throw Errors.entityNotFound("Failed to find entity 'ConnectEntity1' in context")
        }

        for index in Int64(0)..<count {

            let object = ConnectEntity1(entity: entity, insertInto: nil)
            object.id = index

            object.boolAttribute = boolValue
            object.stringAttribute = stringValue
            object.binaryAttribute = dataValue

            objects.append(object)
        }
        return (entity, objects)
    }
}
