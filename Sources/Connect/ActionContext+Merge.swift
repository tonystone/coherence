///
///  ActionContext+Merge.swift
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
///  Created by Tony Stone on 2/5/17.
///
import Foundation
import CoreData
import TraceLog

public extension ActionContext {

    private enum Errors: Error {
        case entityNotManaged(String)
    }

    public func merge<ManagedObjectType: NSManagedObject>(objects: [ManagedObjectType], for entity: NSEntityDescription, subsetFilter: NSPredicate? = nil) throws {

        guard entity.managed else {
            throw Errors.entityNotManaged("Entity \(entity.name ?? "Unknown") not managed, cannot merge objects.")
        }


        let objectSortDescriptors = try self.sortDescriptors(for: entity)

        let objectComparator: (ManagedObjectType, ManagedObjectType) -> ComparisonResult = { (object1, object2) -> ComparisonResult in

            ///
            /// First element that is not orderedSame, return that order
            /// otherwise continue testing until you run out of elements.
            ///
            for sortDescriptor in objectSortDescriptors {

                switch sortDescriptor.compare(object1, to: object2) {

                case .orderedAscending:  return .orderedAscending
                case .orderedDescending: return .orderedDescending
                case .orderedSame: continue
                }
            }
            return .orderedSame
        }

        ///
        /// We need a list of new and existing objects in the same sorted order
        ///
        let newObjects = objects.sorted { (object1, object2) -> Bool in
            return objectComparator(object1, object2) == .orderedAscending
        }

        /// Get the existing ManagedObejcts
        let existingObjects = try { () throws -> [ManagedObjectType] in

            let request = NSFetchRequest<ManagedObjectType>()
            request.entity = entity
            request.predicate = subsetFilter
            request.sortDescriptors = objectSortDescriptors
            request.returnsObjectsAsFaults = false

            return try self.fetch(request) /// This fetch will come back sorted
        }()

        logTrace(1) { "Merging \(newObjects.count) pending object(s) into \(existingObjects.count) exsiting object(s) for entity \(entity.name ?? "Unknown")." }

        var newIterator      = newObjects.makeIterator()
        var existingIterator = existingObjects.makeIterator()

        var newObject      = newIterator.next()
        var existingObject = existingIterator.next()

        /// Loop through both lists, comparing identifiers, until both are empty
        while newObject != nil || existingObject != nil {

            /// Compare identifiers
            let comparisonResult: ComparisonResult

            if newObject == nil {
                /// If the new key list has run out, the new aKey sorts last (i.e. remove remaining existing objects)
                comparisonResult = .orderedDescending
            } else if existingObject == nil {
                /// If existing list has run out, the import aKey sorts first (i.e. add remaining new objects)
                comparisonResult = .orderedAscending
            } else if let newObject      = newObject,
                      let existingObject = existingObject {

                /// If neither list has run out, compare with the object
                comparisonResult = objectComparator(newObject, existingObject)
            } else {
                continue
            }

            if comparisonResult == .orderedSame {
                /// UPDATE: Identifiers match

                if let existingObject = existingObject,
                    let newObject      = newObject {

                    /// Update the existing object with the values from the new object.
                    let objectsAndValues = newObject.dictionaryWithValues(forKeys: Array<String>(entity.attributesByName.keys))

                    existingObject.setValuesForKeys(objectsAndValues)
                }

                ///
                /// Move ahead in both lists.
                ///
                newObject      = newIterator.next()
                existingObject = existingIterator.next()

            } else if comparisonResult == .orderedAscending {
                ///
                /// INSERT: Imported item sorts before stored item
                ///

                if let newObject = newObject {

                    self.insert(newObject)
                }

                ///
                /// Move ahead in just the new list since we used it for an insert.
                ///
                newObject = newIterator.next()

            } else {
                ///
                /// DELETE: Imported item sorts after stored item
                ///

                /// The stored item is not among those imported, and should be removed, then move ahead to the next stored item
                if let existingObject = existingObject {

                    self.delete(existingObject)
                }

                ///
                /// Move ahead just the existing since we deleted it.
                ///
                existingObject = existingIterator.next()
            }
        }
        
        /// Only save this if there are actually changes that took place
        if self.hasChanges {

            try self.save()
        }
    }
}

fileprivate extension ActionContext {

    fileprivate func sortDescriptors(for entity: NSEntityDescription) throws -> [NSSortDescriptor]  {
        var descriptors: [NSSortDescriptor] = []

        for attribute in entity.uniquenessAttributes {
            descriptors.append(NSSortDescriptor(key: attribute, ascending: true))
        }
        return descriptors
    }

}
