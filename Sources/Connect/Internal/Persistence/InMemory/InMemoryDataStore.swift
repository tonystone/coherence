//
//  InMemoryDataStore.swift
//  Pods
//
//  Created by Tony Stone on 8/10/16.
//
//

import Foundation
import CoreData

//extension  {
//    private func sync<R>(@noescape block: () throws -> R) rethrows -> R {
//        pthread_mutex_lock(&m)
//        defer { pthread_mutex_unlock(&m) }
//        return try block()
//    }
//}

//internal
//extension MutableCollection where Index : Strideable, Iterator.Element : AnyObject {
//    
//    /// Sort `self` in-place using criteria stored in a NSSortDescriptors array
//    public mutating func sortInPlace(sortDescriptors theSortDescs: [NSSortDescriptor]) {
//        sort {
//            for sortDesc in theSortDescs {
//                switch sortDesc.compare($0, to: $1) {
//                case .orderedAscending: return true
//                case .orderedDescending: return false
//                case .orderedSame: continue
//                }
//            }
//            return false
//        }
//    }
//}
//
//internal
//class InMemoryDataStore : NSIncrementalStore {
//    
//    internal enum Errors: Error {
//        case initializationFailure(message: String)
//        case objectNotFoundError(message: String)
//        case unsupportedRequestType(message: String)
//        case unsupportedOption(messsage: String)
//    }
//    
//    fileprivate typealias EntityCache =  [NSManagedObjectID : InMemoryReferenceObject]
//    fileprivate typealias StoreCache  = [String : EntityCache]
//    
//    fileprivate var cache        = StoreCache()
//    fileprivate var referenceIDs = [String : Int]()
//    
//    static func storeType() -> String {
//        return String(reflecting: self)
//    }
//
//    // API methods that must be overriden by a subclass:
//    
//    // API methods that may be overriden:
//    override class func identifierForNewStore(at storeURL: URL) -> Any {
//        return NSObject()
//    }
//    
//    // Inform the store that the objects with ids in objectIDs are in use in a client NSManagedObjectContext
//    override func managedObjectContextDidRegisterObjects(with objectIDs: [NSManagedObjectID]) {
//        
//    }
//    
//    // Inform the store that the objects with ids in objectIDs are no longer in use in a client NSManagedObjectContext
//    override func managedObjectContextDidUnregisterObjects(with objectIDs: [NSManagedObjectID]) {
//        
//    }
//
//    // CoreData expects loadMetadata: to validate that the URL used to create the store is usable
//    // (location exists, is writable (if applicable), schema is compatible, etc) and return an
//    // error if there is an issue.
//    // Any subclass of NSIncrementalStore which is file-based must be able to handle being initialized
//    // with a URL pointing to a zero-length file. This serves as an indicator that a new store is to be
//    // constructed at the specified location and allows applications using the store to securly create
//    // reservation files in known locations.
//    override func loadMetadata() throws {
//    
//        // Initialize internal structures
//        guard let model = self.persistentStoreCoordinator?.managedObjectModel,
//              let entitiesForConfiguration = model.entities(forConfigurationName: self.configurationName) else {
//                
//            throw Errors.initializationFailure(message: "Could not access ManagedObjectModel on the PersistentStore")
//        }
//        
//        // Add an entry for this entity into the memory cache
//        for entity in entitiesForConfiguration {
//            
//            if let name = entity.name {
//                self.cache[name]        = EntityCache()
//                self.referenceIDs[name] = 1
//            }
//        }
//        
//        // Set the metadata up.
//        self.metadata = [NSStoreTypeKey : String(reflecting: self),
//                         NSStoreUUIDKey : ProcessInfo.processInfo.globallyUniqueString]
//    }
//
//    // Return a value as appropriate for the request, or nil if the request cannot be completed.
//    // If the request is a fetch request whose result type is set to one of NSManagedObjectResultType,
//    // NSManagedObjectIDResultType, NSDictionaryResultType, return an array containing all objects
//    // in the store matching the request.
//    // If the request is a fetch request whose result type is set to NSCountResultType, return an
//    // array containing an NSNumber of all objects in the store matching the request.
//    // If the request is a save request, the result should be an empty array. Note that
//    // save requests may have nil inserted/updated/deleted/locked collections; this should be
//    // treated as a request to save the store metadata.
//    // Note that subclasses of NSIncrementalStore should implement this method conservatively,
//    // and expect that unknown request types may at some point be passed to the
//    // method. The correct behavior in these cases would be to return nil and an error.
//    override func execute(_ request: NSPersistentStoreRequest, with context: NSManagedObjectContext?) throws -> Any {
//
//        switch request {
//            case let saveRequest as NSSaveChangesRequest:
//                return try self.executeSaveRequest(saveRequest, withContext: context)
//            case let fetchRequest as NSFetchRequest<AnyObject>:
//                return try self.executeFetchRequest(fetchRequest, withContext: context)
//            default:
//                throw Errors.unsupportedRequestType(message: "Unknown request type: \(String(reflecting: request)) request: \(request)")
//        }
//    }
//  
//    // Called before executeRequest with a save request, to assign permanent IDs to newly inserted objects;
//    // must return the objectIDs in the same order as the objects appear in array.
//    override func obtainPermanentIDs(for array: [NSManagedObject]) throws -> [NSManagedObjectID] {
//
//        // Synchronized function
//        objc_sync_enter(referenceIDs)
//        defer { objc_sync_exit(referenceIDs) }
//            
//        var permanentIDs = Array<NSManagedObjectID>()
//        permanentIDs.reserveCapacity(array.count)
//
//        for object in array {
//            if !object.objectID.isTemporaryID {
//                //
//                // Note: When a save request is called, this method is always called for each
//                //       object that is going to be saved regardless of whether it has a permament ID
//                //       or not.  This method may have been called by the user before the save
//                //       which would make the object id permanent.  We don't want to assign a new one
//                //       in this case.
//                //
//                permanentIDs.append(object.objectID)
//            } else {
//                //
//                // In this case we need to generate a new ID for this entity object.
//                //
//                if let name = object.entity.name {
//                    if let permanentID = referenceIDs[name] {
//                    
//                        permanentIDs.append(self.newObjectID(for: object.entity, referenceObject: permanentID))
//                        //
//                        // Update the id to the next available number
//                        //
//                        referenceIDs[name] = permanentID + 1
//                    }
//                }
//                // Note: The else on each of the above is protected by the loadMeta data as it creates an entry for each entity name
//            }
//        }
//        return permanentIDs
//    }
//
//    
//    // Returns an NSIncrementalStoreNode encapsulating the persistent external values for the object for an objectID.
//    // It should include all attributes values and may include to-one relationship values as NSManagedObjectIDs.
//    // Should return nil and set the error if the object cannot be found.
//    override func newValuesForObject(with objectID: NSManagedObjectID, with context: NSManagedObjectContext) throws -> NSIncrementalStoreNode {
//
//        // Synchronized function
//        objc_sync_enter(cache)
//        defer { objc_sync_exit(cache) }
//
//        return try self.referenceObjectWithObjectID(objectID) // Note: will throw an exception if object not found
//    }
//    
//    // Returns the relationship for the given relationship on the object with ID objectID. If the relationship
//    // is a to-one it should return an NSManagedObjectID corresponding to the destination or NSNull if the relationship value is nil.
//    // If the relationship is a to-many, should return an NSSet or NSArray containing the NSManagedObjectIDs of the related objects.
//    // Should return nil and set the error if the source object cannot be found.
//    override func newValue(forRelationship relationship: NSRelationshipDescription, forObjectWith objectID: NSManagedObjectID, with context: NSManagedObjectContext?) throws -> Any  {
//        
//        // Synchronized function
//        objc_sync_enter(cache)
//        defer { objc_sync_exit(cache) }
//
//        let referenceObject = try self.referenceObjectWithObjectID(objectID)
//  
//        return try referenceObject.relationshipFaultValue(relationship)
//    }
//}
//
//private
//extension InMemoryDataStore {
//    
//    func referenceObjectWithObjectID(_ objectID: NSManagedObjectID) throws -> InMemoryReferenceObject  {
//        
//        if let entityName = objectID.entity.name {
//            if let entityReferenceObjects = cache[entityName] {
//                if let object = entityReferenceObjects[objectID] {
//                    return object
//                }
//            }
//        }
//        throw Errors.objectNotFoundError(message: "Managed Object with id \(objectID) not found")
//    }
//    
//      /*
//         If the request is a save request, you record the changes provided in the request’s insertedObjects, updatedObjects, and deletedObjects collections.
//         Note there is also a lockedObjects collection; this collection contains objects which were marked as being tracked for optimistic locking
//         (through the detectConflictsForObject:: method); you may choose to respect this or not.
//
//         In the case of a save request containing objects which are to be inserted, executeRequest:withContext:error: is preceded by a call to
//         obtainPermanentIDsForObjects:error:; Core Data will assign the results of this call as the objectIDs for the objects which are to be inserted.
//         Once these IDs have been assigned, they cannot change. Note that if an empty save request is received by the store, this must be treated as an
//         explicit request to save the metadata, but that store metadata should always be saved if it has been changed since the store was loaded.
//     */
//    func executeSaveRequest(_ request: NSSaveChangesRequest, withContext context: NSManagedObjectContext?) throws -> AnyObject {
//        
//        // Synchronized function
//        objc_sync_enter(cache)
//        defer { objc_sync_exit(cache) }
//        
//        //
//        // Process the inserted objects (attributes only)
//        //
//        for managedObject in request.insertedObjects ?? [] {
//            
//            let referenceObject = InMemoryReferenceObject(anObject: managedObject, version: 1)
//            
//            if let entityName = managedObject.objectID.entity.name {
//                if var entityReferenceObjects = self.cache[entityName] {
//                    
//                    entityReferenceObjects[managedObject.objectID] = referenceObject
//                }
//            }
//        }
//        
//        //
//        // Process the updated objects (attributes only)
//        //
//        for managedObject in request.updatedObjects ?? [] {
//            //
//            // Read the original object
//            //
//            let referenceObject = try self.referenceObjectWithObjectID(managedObject.objectID)
//            
//            // Its easy to get the attributes, get those now
//            referenceObject.update(withObject: managedObject, version: referenceObject.version + 1)
//        }
//        
//        //
//        // Process the delete objects
//        //
//        for managedObject in request.deletedObjects ?? [] {
//            if let entityName = managedObject.objectID.entity.name {
//                if var entityReferenceObjects = cache[entityName] {
//                    //
//                    // Delete from the real store
//                    //
//                    entityReferenceObjects.removeValue(forKey: managedObject.objectID)
//                }
//            }
//        }
//        
//        //
//        // Now reconcile all the relationships
//        //
//        // Note: Since we go through all the objects that have changed,
//        //       we get the inverse of each relationship so no specific
//        //       inverse code is needed.
//        //
//        var requestInsertsAndUpdates = Array<NSManagedObject>()
//        if let inserted = request.insertedObjects {
//            requestInsertsAndUpdates.append(contentsOf: inserted)
//        }
//        if let updated = request.updatedObjects {
//            requestInsertsAndUpdates.append(contentsOf: updated)
//        }
//        
//        for managedObject in requestInsertsAndUpdates {
//            
//            // We need a list of what relationships have changed for this object instance
//            let changedRelationshipNames  = managedObject.changedValues().map({ _,_ in (changed: (String, AnyObject)) -> _ in
//                return changed.0
//            })
//            
//            // If there are any, we translate from the ManagedObject relationships to the Node relationships to link them properly
//            if changedRelationshipNames.count > 0 {
//                let referenceObject = try self.referenceObjectWithObjectID(managedObject.objectID)
//                
//                // Go through all the changed relationship and link them to the localObject
//                for relationshipName in changedRelationshipNames {
//                    
//                    //
//                    // Link the relationship
//                    //
//                    // If this is a toMany relationship the value will be a Set<NSManagedObject>, otherewise a single NAManagedObject
//                    if let relationshipSet = managedObject.primitiveValue(forKey: relationshipName) as? Set<NSManagedObject> {
//                        
//                        var localReferenceRelationshipValue = Set<InMemoryReferenceObject>()
//                        
//                        // Find all the related reference objects and add them to the relationship
//                        for relatedManagedObject in relationshipSet {
//                            
//                            let relatedReferenceObject = try self.referenceObjectWithObjectID(relatedManagedObject.objectID)
//                            
//                            //
//                            // Add this to the local relationship
//                            //
//                            localReferenceRelationshipValue.insert(relatedReferenceObject)
//                        }
//                        
//                        if localReferenceRelationshipValue.count > 0 {
//                            referenceObject.update(withValues: [relationshipName : localReferenceRelationshipValue], version: referenceObject.version)
//                        } else {
//                            referenceObject.update(withValues: [relationshipName : NSNull()], version: referenceObject.version)
//                        }
//                    } else {
//                        // Single NSManagedObject
//                        if let relatedManagedObject = managedObject.primitiveValue(forKey: relationshipName) as? NSManagedObject {
//                            
//                            let relatedReferenceObject = try self.referenceObjectWithObjectID(relatedManagedObject.objectID)
//                            
//                            referenceObject.update(withValues: [relationshipName : relatedReferenceObject], version: referenceObject.version)
//                        } else {
//                            referenceObject.update(withValues: [relationshipName : NSNull()], version: referenceObject.version)
//                        }
//                    }
//                }
//            }
//        }
//        return Array<AnyObject>()
//    }
//
//     /**
//        - executeFetchRequest:context:error:
//
//        If the request is a fetch request, you determine what objects are being requested based on the fetch entity, the value of
//        includesSubentities, and what type of data should be returned (see NSIncrementalStore.h for a more complete description of
//        expected return values). If the expected result type is NSManagedObjectResultType, you should use objectWithID: to create
//        an appropriate instance of the object; note that it is not necessary to populate the managed object with attribute or
//        relationship values at this point (see Faulting below).
//
//        If the request includes a predicate and/or sort descriptors, you use them to filter and/or order the results appropriately.
//
//        You must support the following properties of NSFetchRequest: entity, predicate, sortDescriptors, fetchLimit, resultType, includesSubentities,
//        returnsDistinctResults (in the case of NSDictionaryResultType), propertiesToFetch (in the case of NSDictionaryResultType), fetchOffset,
//        fetchBatchSize, shouldRefreshRefetchedObjects, propertiesToGroupBy, and havingPredicate. If a store does not have underlying support for a
//        feature (propertiesToGroupBy, havingPredicate), it should either emulate the feature in memory or return an error. Note that these are the
//        properties that directly affect the contents of the array to be returned.
//
//        You may optionally ignore the following properties of NSFetchRequest: includesPropertyValues, returnsObjectsAsFaults, relationshipKeyPathsForPrefetching,
//        and includesPendingChanges (this is handled by the managed object context). (These are properties that allow for optimization of I/O and do not affect
//        the results array contents directly.)
//
//        As of iOS 6.x, these are the parameters that need to be considered.
//
//        Managing the Fetch Request’s Entity
//
//        – includesSubentities
//
//        Fetch Constraints
//
//        – predicate                                - Implemented
//        – fetchLimit                               - Implemented
//        – fetchOffset                              - Implemented
//        – fetchBatchSize
//        – affectedStores                           - N/A
//
//        Sorting
//
//        – sortDescriptors                          - Implemented
//
//        Prefetching
//
//        – relationshipKeyPathsForPrefetching       - Will NOT support this feature.
//
//        Managing How Results Are Returned
//
//        – resultType                               - Implemented
//        – includesPendingChanges
//        – propertiesToFetch                        - Implemented (Save NSExpressionDescription)
//        – returnsDistinctResults
//        – includesPropertyValues                   - Will NOT support this feature.  Note: This does not make sense in our case since we're a memory cache, our Row cache is always in memory
//        – shouldRefreshRefetchedObjects            - Implemented
//        – returnsObjectsAsFaults                   - Implemented
//
//        Grouping and Filtering Dictionary Results
//
//        – propertiesToGroupBy
//        – havingPredicate
//
//    */
//    func executeFetchRequest(_ request: NSFetchRequest<AnyObject>, withContext context: NSManagedObjectContext?) throws -> AnyObject {
//
//        // Synchronized function
//        objc_sync_enter(cache)
//        defer { objc_sync_exit(cache) }
//        
//        if let entityName = request.entity?.name,
//           let entityReferenceObjects = self.cache[entityName] {
//            
//            var workingSet = [InMemoryReferenceObject]()
//            
//            /*
//             - predicate
//             
//             The predicate is used to constrain the selection of objects the receiver is to fetch. For more about
//             predicates, see Predicate Programming Guide.
//             
//             If the predicate is empty—for example, if it is an AND predicate whose array of elements contains no
//             predicates—the receiver has its predicate set to nil.
//             */
//            let predicate = request.predicate ?? NSPredicate(value: true)
//            workingSet = entityReferenceObjects.values.filter { predicate.evaluate(with: $0) }
//    
//            /*
//             - sortDescriptors
//             
//             The sort descriptors specify how the objects returned when the fetch request is issued should be ordered—for
//             example by last name then by first name. The sort descriptors are applied in the order in which they appear in
//             the sortDescriptors array (serially in lowest-array-index-first order).
//             */
//            if let sortDescriptors = request.sortDescriptors {
//                workingSet.sortInPlace(sortDescriptors: sortDescriptors)
//            }
//            
//            /*
//             - fetchOffset
//             
//             The default value is 0.
//             
//             This setting allows you to specify an offset at which rows will begin being returned. Effectively, the request
//             will skip over the specified number of matching entries. For example, given a fetch which would normally
//             return a, b, c, d, specifying an offset of 1 will return b, c, d, and an offset of 4 will return an empty array.
//             Offsets are ignored in nested requests such as subqueries.
//             
//             This can be used to restrict the working set of data. In combination with -fetchLimit, you can create a
//             subrange of an arbitrary result set.
//             */
//            var fetchOffset = request.fetchOffset
//            let workingSetCount = workingSet.count
//            
//            if fetchOffset < 0 {
//                
//                fetchOffset = 0
//            } else if fetchOffset > workingSetCount {
//                
//                fetchOffset = workingSetCount - 1
//            }
//            
//            /*
//             - fetchLimit
//             
//             The fetch limit specifies the maximum number of objects that a request should return when executed.
//             
//             If you set a fetch limit, the framework makes a best effort, but does not guarantee, to improve efficiency.
//             For every object store except the SQL store, a fetch request executed with a fetch limit in effect simply
//             performs an unlimited fetch and throws away the unasked for rows.
//             
//             Note: If not set, will be zero 0
//             */
//            var fetchLimit = request.fetchLimit
//            
//            if fetchLimit < 0 || fetchLimit > workingSetCount - fetchOffset - 1 {
//                
//                fetchLimit = workingSetCount - fetchOffset - 1
//            }
//            
////            let fetchRange = fetchOffset..<fetchLimit
////
////
////            workingSet = workingSet[fetchRange]
//            
//        // let fetchBachSize = request.fetchBatchSize
//
//
//            /*
//             - resultType
//             
//             The default value is NSManagedObjectResultType.
//             
//             You use setResultType: to set the instance type of objects returned from executing the request—for possible
//             values, see “NSFetchRequestResultType.” If you set the value to NSManagedObjectIDResultType, this will demote
//             any sort orderings to “best efforts” hints if you do not include the property values in the request.
//             
//             Special Considerations
//             
//             See also setIncludesPendingChanges: for a discussion the interaction of result type with whether pending changes are taken into account.
//             */
//            switch request.resultType {
//                
//            case NSFetchRequestResultType.managedObjectIDResultType: return try self.managedObjectIDResult(workingSet, request: request, context: context)
//
//            case NSFetchRequestResultType.dictionaryResultType:      return try self.dictionaryResult(workingSet, request: request, context: context)
//      
//            case NSFetchRequestResultType.countResultType:           return try self.countResult(workingSet, request: request, context: context)
//                
//            case NSFetchRequestResultType():   return try self.managedObjectResult(workingSet, request: request, context: context)
//                
//            default:
//                throw Errors.unsupportedRequestType(message: "Result type \(request.resultType) not supported by \(String(reflecting: self))")
//            }
//        }
//        return []
//    }
//    
//    func managedObjectIDResult(_ workingSet: [InMemoryReferenceObject], request: NSFetchRequest<AnyObject>, context: NSManagedObjectContext?) throws -> [NSManagedObjectID] {
//
//        var result = [NSManagedObjectID]()
//        result.reserveCapacity(workingSet.count)
//        
//        for referenceObject in workingSet {
//            result.append(referenceObject.objectID)
//        }
//        return result;
//    }
//
//     /*
//     These are specific to the Dictionary return type
//
//     Managing How Results Are Returned
//
//     – propertiesToFetch                    - Implemented
//     – returnsDistinctResults               - Implemented (not fully functional yet)
//
//     Grouping and Filtering Dictionary Results
//
//     – propertiesToGroupBy
//     – havingPredicate
//
//     */
//    func dictionaryResult(_ workingSet: [InMemoryReferenceObject], request: NSFetchRequest<AnyObject>, context: NSManagedObjectContext?) throws -> [String : AnyObject] {
//
//        var properties = [NSPropertyDescription]()
//
//        /*
//         – returnsDistinctResults
//
//             Determines whether the request should return only distinct values for the fields specified by propertiesToFetch.
//             If YES, the request returns only distinct values for the fields specified by propertiesToFetch.
//         */
//        if request.returnsDistinctResults {
//            // WARNING: A custom sublcass of NSDictionary needs to be created to add to the set in order for returnsDistinctResults to work with this set.
//            throw Errors.unsupportedOption(messsage: "Store type \(String(reflecting: self)) does not suppert fetch request property returnsDistinctResults")
//        }
//
//        /*
//         – propertiesToGroupBy
//
//             If you use this setting, then you must set the resultType to NSDictionaryResultType,
//             and the SELECT values must be literals, aggregates, or columns specified in the GROUP BY.
//             Aggregates will operate on the groups specified in the GROUP BY rather than the whole table.
//             If you set properties to group by, you can also set a having predicate—see setHavingPredicate:.
//         */
//        if (request.propertiesToGroupBy != nil) { // Not implemented yet
//
//            /*
//             – havingPredicate
//
//                 Sets the predicate to use to filter rows being returned by a query containing a GROUP BY.
//
//                 The predicate to use to filter rows being returned by a query containing a GROUP BY.
//
//                 If a having predicate is supplied, it will be run after the GROUP BY. Specifying a HAVING predicate
//                 requires that a GROUP BY also be specified. For a discussion of GROUP BY, see setPropertiesToGroupBy:.
//             */
//            if (request.havingPredicate != nil) { // Not implemented yet
//
//            }
//        }
//
//        /*
//         – propertiesToFetch
//
//             The property descriptions may represent attributes, to-one relationships, or expressions. The name of an attribute
//             or relationship description must match the name of a description on the fetch request’s entity.
//
//             This value is only used if resultType is set to NSDictionaryResultType.
//         */
//        //
//        // Note: NSFetchRequest verifies the parameters are correct
//        //       and that we only get the proper types of attribtues
//        //       here so we can safely just take the list as is.
//        //
//        if let propertiesToFetch = request.propertiesToFetch as? [NSPropertyDescription] {
//
//            properties.append(contentsOf: propertiesToFetch)
//            
//        } else if let propertyNamesToFetch = request.propertiesToFetch as? [String] {
//            
//            if let propertiesByName = request.entity?.attributesByName {
//            
//                for propertyName in propertyNamesToFetch {
//                    
//                    if let property = propertiesByName[propertyName] {
//                        properties.append(property)
//                    }
//                }
//            }
//            
//        } else {
//            //
//            // The property descriptions that represent attributes and to-one relationships
//            //
//            for property in request.entity?.properties ?? [] {
//                
//                if let property = property as? NSRelationshipDescription {
//                    if property.isToMany {
//                        properties.append(property)
//                    }
//                } else {
//                    properties.append(property)
//                }
//            }
//        }
//        
//        var result = [String : AnyObject]()
//        
//        //
//        // Process the working set for the properties
//        // calculated above.
//        //
//        for referenceObject in workingSet {
//
//            for property in properties {
//                let propertyName = property.name
//                
//                if property is NSAttributeDescription {
//                    
//                    //
//                    // Attributes are simply copied
//                    //
//                    result[propertyName] = referenceObject.value(forKey: propertyName)
//
//                } else if property is NSRelationshipDescription {
//                    //
//                    // Relationships are faulted in or null
//                    //
//                    if let relatedObject = referenceObject.value(forKey: propertyName) as? NSManagedObject {
//
//                        result[propertyName] = relatedObject.objectID
//                    } else {
//                        result[propertyName] = NSNull()
//                    }
//                } else {
//                    /*
//                     Its an expression.
//
//                     These are going to be very difficult to evaluate in the in memory. Mainly because
//                     they may be an aggragate or a per object expression.
//
//
//                     Here's an example of an aggragate expression:
//
//                        // Specify that the request should return dictionaries.
//                        [request setResultType:NSDictionaryResultType];
//
//                        // Create an expression for the key path.
//                        NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"sequenceNumber"];
//
//                        // Create an expression to represent the maximum value at the key path 'creationDate'
//                        NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
//
//                        // Create an expression description using the maxExpression and returning a date.
//                        NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
//
//                        // The name is the key that will be used in the dictionary for the return value.
//                        [expressionDescription setName:@"maxSequenceNumber"];
//                        [expressionDescription setExpression:maxExpression];
//                        [expressionDescription setExpressionResultType:NSInteger32AttributeType];
//
//                        // Set the request's properties to fetch just the property represented by the expressions.
//                        [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
//
//                     */
//                    throw Errors.unsupportedRequestType(message: "Store type \(String(reflecting: self)) does not suppert fetch request with NSExpressionDescriptions")
//                }
//            }
//        }
//        return result
//    }
//    
//    /*
//         Settings that are specific to ObjectResults type
//
//         - includesPropertyValues               - This does not make sense in our case since we're a memory cache, our Row cache is always in memory
//         - shouldRefreshRefetchedObjects        - Implemented
//         - returnsObjectsAsFaults               - Implemented
//         - relationshipKeyPathsForPrefetching   - Will NOT support this feature
//         – includesPendingChanges
//
//     */
//    func managedObjectResult(_ workingSet: [InMemoryReferenceObject], request: NSFetchRequest<AnyObject>, context: NSManagedObjectContext?) throws -> [NSManagedObjectID] {
////        
////        NSMutableArray * result = [[NSMutableArray alloc] initWithCapacity: [workingSet count]];
////
////        //
////        // NOTE: These are checked here and put into local values
////        //       to avoid possible costly method calls in loops. This is
////        //       an optimization and also serves to state explicitly
////        //       what features are implemented for this result type.
////        //
////        BOOL returnsObjectsAsFaults                  = [request returnsObjectsAsFaults];
////        BOOL includesPendingChanges                  = [request includesPendingChanges];
////        BOOL shouldRefreshRefetchedObjects           = [request shouldRefreshRefetchedObjects];
////        //NSArray * relationshipKeyPathsForPrefetching = [request relationshipKeyPathsForPrefetching];
////
////        /*
////         – includesPendingChanges
////
////             Sets if, when the fetch is executed, it matches against currently unsaved changes in the managed object context.
////             If YES, when the fetch is executed it will match against currently unsaved changes in the managed object context.
////
////             The default value is YES.
////
////             If the value is NO, the fetch request skips checking unsaved changes and only returns objects that matched the predicate in the persistent store.
////
////             A value of YES is not supported in conjunction with the result type NSDictionaryResultType, including calculation of
////             aggregate results (such as max and min). For dictionaries, the array returned from the fetch reflects the current state in
////             the persistent store, and does not take into account any pending changes, insertions, or deletions in the context.
////         */
////        if (includesPendingChanges) {
////            // Collesce the objects in the context for the entitySpecified.
////            // Apply the changes to the working set including deleting referenceObjects from the set
////            // Rerun the predicate on the new working set creating a new working set
////            // Continue with the rest of the processing
////            //
////            // OR
////            //
////            // Ignoring this for now.  The documentation says you can ignore this option.
////        }
////
////        //
////        // Fault in the objects and add them to the results
////        //
////        for (MGInMemoryReferenceObject * referenceObject in workingSet) {
////            NSManagedObject * object = [context objectWithID: [referenceObject objectID]];
////            [result addObject: object];
////
////            /*
////             - returnsObjectsAsFaults
////
////             Returns a Boolean value that indicates whether the objects resulting from a fetch using the receiver are faults.
////
////             YES if the objects resulting from a fetch using the receiver are faults, otherwise NO.
////
////             The default value is YES. This setting is not used if the result type (see resultType) is NSManagedObjectIDResultType, as object IDs do not
////             have property values. You can set returnsObjectsAsFaults to NO to gain a performance benefit if you know you will need to access the
////             property values from the returned objects.
////
////             By default, when you execute a fetch returnsObjectsAsFaults is YES; Core Data fetches the object data for the matching records, fills the
////             row cache with the information, and returns managed object as faults. These faults are managed objects, but all of their property data
////             resides in the row cache until the fault is fired. When the fault is fired, Core Data retrieves the data from the row cache. Although the
////             overhead for this operation is small, for large datasets it may become non-trivial. If you need to access the property values from the
////             returned objects (for example, if you iterate over all the objects to calculate the average value of a particular attribute), then it is
////             more efficient to set returnsObjectsAsFaults to NO to avoid the additional overhead.
////             */
////            if (returnsObjectsAsFaults) {
////                if (![object isFault]) {
////                    // Make it a fault
////                    [context refreshObject: object mergeChanges: NO];
////                }
////            } else {
////                //
////                // NOTE: All fetch settings in this ELSE seem to only
////                //       make sense if returnsObjectAsFaults is NO.
////                //
////                if ([object isFault]) {
////                    //
////                    // Note that this actually fires the fault and makes another
////                    // callback to newValuesForObjectWithID:withContext:error:.
////                    //
////                    // This is the only way I know to force the fault to fire.
////                    // Settings the values from
////                    //
////                    [object willAccessValueForKey: nil];
////
////                } else if (shouldRefreshRefetchedObjects) {
////                    /*
////                     - shouldRefreshRefetchedObjects
////
////                     Sets whether the fetch request should cause property values of fetched objects to be updated with the current values in the persistent store.
////
////                     YES if the fetch request should cause property values of fetched objects to be updated with the current values in the persistent store, otherwise NO.
////
////                     By default, when you fetch objects they maintain their current property values, even if the values in the persistent store have changed. By invoking
////                     this method with the parameter YES, when the fetch is executed the property values of fetched objects to be updated with the current values in the
////                     persistent store. This provides more convenient way to ensure managed object property values are consistent with the store than by
////                     using refreshObject:mergeChanges: (NSManagedObjetContext) for multiple objects in turn.
////                     */
////                    [context refreshObject: object mergeChanges: YES];
////                }
////            }
////        }
////        return result;
//        return [NSManagedObjectID]()
//    }
//
//
//
//   
//    /*
//        This one is very simple since we only need the result count
//        */
//    func countResult(_ workingSet: [InMemoryReferenceObject], request: NSFetchRequest<AnyObject>, context: NSManagedObjectContext?) throws -> [NSNumber] {
////    - (id) countResultFromWorkingSet: (NSArray *) workingSet forFetchRequest: (NSFetchRequest *)request context: (NSManagedObjectContext *) context error:(NSError *__autoreleasing *)error {
////        return [[NSArray alloc] initWithObjects:[NSNumber numberWithUnsignedInteger: [workingSet count]], nil];
//        return [NSNumber]()
//    }
//}
