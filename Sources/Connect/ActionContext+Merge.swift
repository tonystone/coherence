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

    ///
    /// Merge `objects` into the database.
    ///
    /// - Throws: `Coherence.Errors.unmanagedEntity` if the `for entity` is not managed by `Connect`
    ///
    public func merge<ManagedObjectType: NSManagedObject>(objects: [ManagedObjectType], for entity: NSEntityDescription, subsetFilter: NSPredicate? = nil) throws {

        guard let entityName = entity.name else {
            throw Errors.missingEntityName("Entity does not have a name, cannot merge objects.")
        }
        guard entity.managed else {
            throw Errors.unmanagedEntity("Entity '\(entityName)' not managed, cannot merge objects.")
        }

        ///
        /// Get a list of exceptions for the merge from the transaction log
        ///
        let localTransactions = try { () throws -> LogRecords in
            if let results = try logger?.transactionLogRecordTypesForEntity(entity) {
                return LogRecords(results)
            }
            return LogRecords([:])
        }()

        ///
        /// Create the sort descriptors to sort both the source objects and the persistent objects.
        ///
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

        /// Get the existing ManagedObjects
        let existingObjects = try { () throws -> [ManagedObjectType] in

            let request = NSFetchRequest<ManagedObjectType>()
            request.entity = entity
            request.predicate = subsetFilter
            request.sortDescriptors = objectSortDescriptors
            request.returnsObjectsAsFaults = false

            return try self.fetch(request) /// This fetch will come back sorted
        }()

        logTrace(Log.tag, level: 1) { "Merging \(newObjects.count) pending object(s) into \(existingObjects.count) existing object(s) for entity \(entityName)." }

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
                comparisonResult = .orderedSame
            }

            if comparisonResult == .orderedSame {
                /// UPDATE: Identifiers match

                if let existingObject = existingObject,
                   let newObject      = newObject {

                    /// Get a local transaction based on the existing object in the cache, if any
                    if localTransactions.hasRecord(for: existingObject.uniqueueIDString(), type: .update) {
                        ///
                        /// Note: LOCAL UPDATE: Only update the local copy if our local copy has not been changed
                        ///                     This will preserve the transaction log and allow it to update the
                        ///                     server later
                        ///
                        /// ------------------------------------------------------------------------------------------
                        ///
                        ///       LOCAL DELETE: A local delete would never match a key in the database, instead, this would
                        ///                     show up as an insert
                        ///
                        ///       LOCAL INSERT: An insert on our side would never match the resource reference on this side
                        ///

                        /// We assume that once we update the server with our local update, the condition below
                        /// will com into affect and the values will merged.
                    } else {

                        /// Update the existing object with the values from the new object.
                        let objectsAndValues = newObject.dictionaryWithValues(forKeys: Array<String>(entity.attributesByName.keys))
                        
                        existingObject.setValuesForKeys(objectsAndValues)
                    }
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

                    // Get a local transaction based on the merging object, if any
                    if localTransactions.hasRecord(for: newObject.uniqueueIDString(), type: .delete) {
                        ///
                        /// Note: LOCAL DELETE: A local  deleted record is the only condition that we
                        ///                     care about here and need to deal with.  In this case the
                        ///                     record is not in our local cache but has not yet been deleted
                        ///                     from the server.  It still remains in our transaction log though
                        ///
                        /// ------------------------------------------------------------------------------------------
                        ///
                        ///       LOCAL UPDATE: A record that has been updated locally would not match the resource
                        ///                     reference of a record from the server we consider new
                        ///
                        ///       LOCAL INSERT: An insert on our side would never match the resource reference
                        ///                     of a server inserted record  so we let the new record be inserted
                        ///

                        /// The object on the server has been deleted locally and has not yet updated the server
                        /// We do not need to deal with this here.  The server will be updated in time
                    } else {

                        self.insert(newObject)
                    }
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

                    // Get a local transaction based on the existing object in the cache, if any

                    if localTransactions.hasRecord(for: existingObject.uniqueueIDString(), type: .update) {
                        ///
                        /// Note: LOCAL UPDATE: A local update to a deleted record is the only condition that we
                        ///                     care about here and need to deal with.
                        ///
                        /// ------------------------------------------------------------------------------------------
                        ///
                        ///       LOCAL DELETE: A delete on both sides requires no action here because it is
                        ///                     already removed from our local cache
                        ///
                        ///       LOCAL INSERT: An insert on our side would never match the resource reference on this side
                        ///

                        /// Merge conflict, we need to store the fact and notify the user that this object
                        /// has been removed
                    } else {

                        self.delete(existingObject)
                    }
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

    fileprivate class LogRecords {

        private let records: [String: Set<MetaLogEntryType>]

        init(_ records: [String: Set<MetaLogEntryType>]) {
            self.records = records
        }

        @inline(__always)
        func hasRecord(for uniqueID: String?, type: MetaLogEntryType) -> Bool {
            guard let uniqueID = uniqueID, let types = records[uniqueID]
                else { return false }

            return types.contains(type)
        }
    }

    fileprivate func sortDescriptors(for entity: NSEntityDescription) throws -> [NSSortDescriptor]  {
        var descriptors: [NSSortDescriptor] = []

        for attribute in entity.uniquenessAttributes {
            descriptors.append(NSSortDescriptor(key: attribute, ascending: true))
        }
        return descriptors
    }

}
