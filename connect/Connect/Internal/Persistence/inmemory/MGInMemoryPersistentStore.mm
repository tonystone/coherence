//
// Created by Tony Stone on 7/2/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGInMemoryPersistentStore.h"
#import "MGInMemoryReferenceObject.h"

@implementation MGInMemoryPersistentStore {
        NSMutableDictionary * cache;
        NSMutableDictionary * referenceIDs;
    }

    + (NSString *) storeType {
        return NSStringFromClass(self);
    }

    - (BOOL) loadMetadata: (NSError **) error {
    
        // Initialize internal structures
        NSManagedObjectModel * model                    = [[self persistentStoreCoordinator] managedObjectModel];
        NSArray              * entitiesForConfiguration = [model entitiesForConfiguration: [self configurationName]];
        
        cache        = [[NSMutableDictionary alloc] initWithCapacity: [entitiesForConfiguration count]];
        referenceIDs = [[NSMutableDictionary alloc] initWithCapacity: [entitiesForConfiguration count]];
        
        for (NSEntityDescription * entity in entitiesForConfiguration) {
            cache       [[entity name]] = [[NSMutableDictionary alloc] init];
            referenceIDs[[entity name]] = @1;
        }  
        
        // Set the metadata up.
        NSString * uuid      = [[NSProcessInfo processInfo] globallyUniqueString];
        NSString * storeType = NSStringFromClass([self class]);
        
        [self setMetadata: @{NSStoreTypeKey: storeType,
                             NSStoreUUIDKey: uuid}];
    
        return YES;
    }

    - (id) executeRequest:(NSPersistentStoreRequest *)request withContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error {

        switch ([request requestType]) {
            case NSSaveRequestType:  return [self executeSaveRequest:  (NSSaveChangesRequest *) request context: context error: error];
            case NSFetchRequestType: return [self executeFetchRequest: (NSFetchRequest *)       request context: context error: error];
            default:
            {
                NSString * errorString = [NSString stringWithFormat: @"Unknown request type: %u request: %@", [request requestType], request];
                if (error) {
                    *error = [NSError errorWithDomain: @"MGErrorDomain" code: -1200 userInfo: @{NSLocalizedDescriptionKey: errorString}];
                }
                break;
            }
        }
        return nil;
    }

    /*
         - executeSaveRequest:context:error:

         If the request is a save request, you record the changes provided in the request’s insertedObjects, updatedObjects, and deletedObjects collections.
         Note there is also a lockedObjects collection; this collection contains objects which were marked as being tracked for optimistic locking
         (through the detectConflictsForObject:: method); you may choose to respect this or not.

         In the case of a save request containing objects which are to be inserted, executeRequest:withContext:error: is preceded by a call to
         obtainPermanentIDsForObjects:error:; Core Data will assign the results of this call as the objectIDs for the objects which are to be inserted.
         Once these IDs have been assigned, they cannot change. Note that if an empty save request is received by the store, this must be treated as an
         explicit request to save the metadata, but that store metadata should always be saved if it has been changed since the store was loaded.

     */
    - (id) executeSaveRequest: (NSSaveChangesRequest *)request context: (NSManagedObjectContext *) context error:(NSError *__autoreleasing *)error {

        NSParameterAssert(request != nil);
        NSParameterAssert(context != nil);

        id result = nil;

        @synchronized(cache) {
            //
            // Process the inserted objects (attributes only)
            //
            for (NSManagedObject * managedObject in [request insertedObjects]) {

                MGInMemoryReferenceObject * referenceObject = [[MGInMemoryReferenceObject alloc] initWithObject: managedObject version: 1];

                NSMutableDictionary * entityReferenceObjects = [cache objectForKey: [[[managedObject objectID] entity] name]];

                [entityReferenceObjects setObject: referenceObject forKey: [managedObject objectID]];
            }

            //
            // Process the updated objects (attributes only)
            //
            for (NSManagedObject * managedObject in [request updatedObjects]) {
                //
                // Read the original object
                //
                MGInMemoryReferenceObject * referenceObject = [self referenceObjectWithObjectID: [managedObject objectID]];

                // Its easy to get the attributes, get those now
                [referenceObject updateAttributesWithObject: managedObject version: [referenceObject version]+1];
            }

            //
            // Process the delete objects
            //
            for (NSManagedObject * managedObject in [request deletedObjects]) {
                NSMutableDictionary * entityReferenceObjects = [cache objectForKey: [[[managedObject objectID] entity] name]];
                //
                // Delete from the real store
                //
                [entityReferenceObjects removeObjectForKey: [managedObject objectID]];
            }

            //
            // Now reconcile all the relationships
            //
            // Note: Since we go through all the objects that have changed,
            //       we get the inverse of each relationship so no specific
            //       inverse code is needed.
            //
            NSSet * requestInsertsAndUpdates = [[request insertedObjects] setByAddingObjectsFromSet: [request updatedObjects]];

            for (NSManagedObject * managedObject in requestInsertsAndUpdates) {

                NSDictionary * relationships = [[managedObject entity] relationshipsByName];
                NSDictionary * changedRelationshipValues = [[managedObject changedValues] dictionaryWithValuesForKeys: [relationships allKeys]];

                if ([changedRelationshipValues count] > 0) {
                    MGInMemoryReferenceObject * referenceObject = [self referenceObjectWithObjectID: [managedObject objectID]];

                    // Go through all the changed relationship values and link them to the localObject
                    for (NSString * relationshipName in [changedRelationshipValues allKeys]) {
                        NSRelationshipDescription * relationshipDescription = [relationships objectForKey: relationshipName];

                        id localRelationshipValue = nil;

                        //
                        // Link the relationship
                        //
                        if ([relationshipDescription isToMany]) {

                            localRelationshipValue = [[NSMutableSet alloc] init];

                            for (NSManagedObject * relatedObject in [managedObject primitiveValueForKey: relationshipName]) {

                                NSManagedObjectID * relatedObjectID = [relatedObject objectID];
                                MGInMemoryReferenceObject   * relatedReferenceObject = [self referenceObjectWithObjectID: relatedObjectID];

                                //
                                // Add this to the local relationship
                                //
                                if (relatedReferenceObject) {
                                    [localRelationshipValue addObject: relatedReferenceObject];
                                }
                            }

                            if ([localRelationshipValue count] == 0) {
                                localRelationshipValue = nil;
                            }

                        } else {
                            // Single object
                            NSManagedObjectID * relatedObjectID = [[managedObject primitiveValueForKey: relationshipName] objectID];
                            if (relatedObjectID) {
                                localRelationshipValue = [self referenceObjectWithObjectID: relatedObjectID];
                            } else {
                                localRelationshipValue = nil;
                            }
                        }

                        if (localRelationshipValue) {
                            //
                            // This will either be a set or a NSManagedObject
                            //
                            [referenceObject setPrimitiveValue: localRelationshipValue forKey: relationshipName];
                        }
                    }
                }
            }
            result = @[];
        }
        return result;
    }

    - (NSArray *)obtainPermanentIDsForObjects:(NSArray *)array error:(NSError *__autoreleasing *)error {

        NSParameterAssert(array != nil);

        NSMutableArray * permanentIDs = [[NSMutableArray alloc] initWithCapacity: [array count]];

        @synchronized(referenceIDs) {

            for (NSManagedObject * object in array) {

                if (![[object objectID] isTemporaryID]) {
                    //
                    // Note: When a save request is called, this method is always called for each
                    //       object that is going to be saved regardless of whether it has a permament ID
                    //       or not.  This method may have been called by the user before the save
                    //       which would make the object id permanent.  We don't want to assign a new one
                    //       in this case.
                    //
                    [permanentIDs addObject: [object objectID]];

                } else {
                    //
                    // In this case we need to generate a new ID for this entity object.
                    //
                    NSNumber * permanentID = [referenceIDs objectForKey: [[object entity] name]];
                    [permanentIDs addObject: [self newObjectIDForEntity: [object entity]  referenceObject: permanentID]];

                    //
                    // Update the id to the next available number
                    //
                    [referenceIDs setObject: [NSNumber numberWithUnsignedInteger: [permanentID unsignedIntegerValue]+1] forKey: [[object entity] name]];
                }
            }
        }
        return permanentIDs;
    }

    /**
        - executeFetchRequest:context:error:

        If the request is a fetch request, you determine what objects are being requested based on the fetch entity, the value of
        includesSubentities, and what type of data should be returned (see NSIncrementalStore.h for a more complete description of
        expected return values). If the expected result type is NSManagedObjectResultType, you should use objectWithID: to create
        an appropriate instance of the object; note that it is not necessary to populate the managed object with attribute or
        relationship values at this point (see Faulting below).

        If the request includes a predicate and/or sort descriptors, you use them to filter and/or order the results appropriately.

        You must support the following properties of NSFetchRequest: entity, predicate, sortDescriptors, fetchLimit, resultType, includesSubentities,
        returnsDistinctResults (in the case of NSDictionaryResultType), propertiesToFetch (in the case of NSDictionaryResultType), fetchOffset,
        fetchBatchSize, shouldRefreshRefetchedObjects, propertiesToGroupBy, and havingPredicate. If a store does not have underlying support for a
        feature (propertiesToGroupBy, havingPredicate), it should either emulate the feature in memory or return an error. Note that these are the
        properties that directly affect the contents of the array to be returned.

        You may optionally ignore the following properties of NSFetchRequest: includesPropertyValues, returnsObjectsAsFaults, relationshipKeyPathsForPrefetching,
        and includesPendingChanges (this is handled by the managed object context). (These are properties that allow for optimization of I/O and do not affect
        the results array contents directly.)

        As of iOS 6.x, these are the parameters that need to be considered.

        Managing the Fetch Request’s Entity

        – includesSubentities

        Fetch Constraints

        – predicate                                - Implemented
        – fetchLimit                               - Implemented
        – fetchOffset                              - Implemented
        – fetchBatchSize
        – affectedStores                           - N/A

        Sorting

        – sortDescriptors                          - Implemented

        Prefetching

        – relationshipKeyPathsForPrefetching       - Will NOT support this feature.

        Managing How Results Are Returned

        – resultType                               - Implemented
        – includesPendingChanges
        – propertiesToFetch                        - Implemented (Save NSExpressionDescription)
        – returnsDistinctResults
        – includesPropertyValues                   - Will NOT support this feature.  Note: This does not make sense in our case since we're a memory cache, our Row cache is always in memory
        – shouldRefreshRefetchedObjects            - Implemented
        – returnsObjectsAsFaults                   - Implemented

        Grouping and Filtering Dictionary Results

        – propertiesToGroupBy
        – havingPredicate

    */
    - (id) executeFetchRequest: (NSFetchRequest *)request context: (NSManagedObjectContext *) context error:(NSError *__autoreleasing *)error {

        NSParameterAssert(request != nil);
        NSParameterAssert([request entity] != nil);
        NSParameterAssert(context != nil);

        id result = nil;

        @synchronized(cache) {

            NSMutableDictionary * entityReferenceObjects = [cache objectForKey: [[request entity] name]];
            NSArray             * workingSet             = nil;

            //
            // NOTE: These are checked here and put into local values
            //       to avoid possible costly method calls in loops. This is
            //       an optimization and also serves to state explicitly
            //       what features are implemented for this result type.
            //
            NSUInteger fetchLimit                        = [request fetchLimit];
            NSUInteger fetchOffset                       = [request fetchOffset];
            //NSUInteger fetchBatchSize                    = [request fetchBatchSize];

            /*
             - predicate

             The predicate is used to constrain the selection of objects the receiver is to fetch. For more about
             predicates, see Predicate Programming Guide.

             If the predicate is empty—for example, if it is an AND predicate whose array of elements contains no
             predicates—the receiver has its predicate set to nil.
             */
            if ([request predicate]) {
                workingSet = [[entityReferenceObjects allValues] filteredArrayUsingPredicate: [request predicate]];
            } else {
                workingSet = [entityReferenceObjects allValues];
            }

            /*
             - sortDescriptors

             The sort descriptors specify how the objects returned when the fetch request is issued should be ordered—for
             example by last name then by first name. The sort descriptors are applied in the order in which they appear in
             the sortDescriptors array (serially in lowest-array-index-first order).
             */
            if ([request sortDescriptors]) {
                workingSet = [workingSet sortedArrayUsingDescriptors: [request sortDescriptors]];
            }

            /*
             - fetchOffset

             The default value is 0.

             This setting allows you to specify an offset at which rows will begin being returned. Effectively, the request
             will skip over the specified number of matching entries. For example, given a fetch which would normally
             return a, b, c, d, specifying an offset of 1 will return b, c, d, and an offset of 4 will return an empty array.
             Offsets are ignored in nested requests such as subqueries.

             This can be used to restrict the working set of data. In combination with -fetchLimit, you can create a
             subrange of an arbitrary result set.
             */
            if (fetchOffset) {
                NSUInteger workingSetCount = [workingSet count];
                NSRange    subArrayRange   = {workingSetCount-1, 0};

                if (fetchOffset <= workingSetCount) {
                    subArrayRange.location = fetchOffset;
                    subArrayRange.length   = workingSetCount - fetchOffset;
                }
                workingSet = [workingSet subarrayWithRange: subArrayRange];
            }

            /*
             - fetchLimit

             The fetch limit specifies the maximum number of objects that a request should return when executed.

             If you set a fetch limit, the framework makes a best effort, but does not guarantee, to improve efficiency.
             For every object store except the SQL store, a fetch request executed with a fetch limit in effect simply
             performs an unlimited fetch and throws away the unasked for rows.
             */
            if (fetchLimit) {   // If not set, will be zero 0
                NSUInteger workingSetCount = [workingSet count];
                NSRange    subArrayRange   = {0, workingSetCount-1};

                if (fetchLimit < workingSetCount) {
                    subArrayRange.length = fetchLimit;
                }
                workingSet = [workingSet subarrayWithRange: subArrayRange];
            }

            /*
             - resultType

             The default value is NSManagedObjectResultType.

             You use setResultType: to set the instance type of objects returned from executing the request—for possible
             values, see “NSFetchRequestResultType.” If you set the value to NSManagedObjectIDResultType, this will demote
             any sort orderings to “best efforts” hints if you do not include the property values in the request.

             Special Considerations

             See also setIncludesPendingChanges: for a discussion the interaction of result type with whether pending changes are taken into account.
             */
            switch ([request resultType]) {

                case NSManagedObjectIDResultType:
                {
                    result = [self managedObjectIDResultFromWorkingSet: workingSet forFetchRequest: request context: context error: error];
                    break;
                }
                case NSDictionaryResultType:
                {
                    result = [self dictionaryResultFromWorkingSet: workingSet forFetchRequest: request context: context error: error];
                    break;
                }
                case NSCountResultType:
                {
                    result = [self countResultFromWorkingSet: workingSet forFetchRequest: request context: context error: error];
                    break;
                }
                case NSManagedObjectResultType:
                default:
                {
                    result = [self managedObjectResultFromWorkingSet: workingSet forFetchRequest: request context: context error: error];
                    break;
                }
            }
        }
        return result;
    }

    /*
         Settings that are specific to ObjectResults type

         - includesPropertyValues               - This does not make sense in our case since we're a memory cache, our Row cache is always in memory
         - shouldRefreshRefetchedObjects        - Implemented
         - returnsObjectsAsFaults               - Implemented
         - relationshipKeyPathsForPrefetching   - Will NOT support this feature
         – includesPendingChanges

     */
    - (id) managedObjectResultFromWorkingSet: (NSArray *) workingSet forFetchRequest: (NSFetchRequest *)request context: (NSManagedObjectContext *) context error:(NSError *__autoreleasing *)error {

        NSMutableArray * result = [[NSMutableArray alloc] initWithCapacity: [workingSet count]];

        //
        // NOTE: These are checked here and put into local values
        //       to avoid possible costly method calls in loops. This is
        //       an optimization and also serves to state explicitly
        //       what features are implemented for this result type.
        //
        BOOL returnsObjectsAsFaults                  = [request returnsObjectsAsFaults];
        BOOL includesPendingChanges                  = [request includesPendingChanges];
        BOOL shouldRefreshRefetchedObjects           = [request shouldRefreshRefetchedObjects];
        //NSArray * relationshipKeyPathsForPrefetching = [request relationshipKeyPathsForPrefetching];

        /*
         – includesPendingChanges

             Sets if, when the fetch is executed, it matches against currently unsaved changes in the managed object context.
             If YES, when the fetch is executed it will match against currently unsaved changes in the managed object context.

             The default value is YES.

             If the value is NO, the fetch request skips checking unsaved changes and only returns objects that matched the predicate in the persistent store.

             A value of YES is not supported in conjunction with the result type NSDictionaryResultType, including calculation of
             aggregate results (such as max and min). For dictionaries, the array returned from the fetch reflects the current state in
             the persistent store, and does not take into account any pending changes, insertions, or deletions in the context.
         */
        if (includesPendingChanges) {
            // Collesce the objects in the context for the entitySpecified.
            // Apply the changes to the working set including deleting referenceObjects from the set
            // Rerun the predicate on the new working set creating a new working set
            // Continue with the rest of the processing
            //
            // OR
            //
            // Ignoring this for now.  The documentation says you can ignore this option.
        }

        //
        // Fault in the objects and add them to the results
        //
        for (MGInMemoryReferenceObject * referenceObject in workingSet) {
            NSManagedObject * object = [context objectWithID: [referenceObject objectID]];
            [result addObject: object];

            /*
             - returnsObjectsAsFaults

             Returns a Boolean value that indicates whether the objects resulting from a fetch using the receiver are faults.

             YES if the objects resulting from a fetch using the receiver are faults, otherwise NO.

             The default value is YES. This setting is not used if the result type (see resultType) is NSManagedObjectIDResultType, as object IDs do not
             have property values. You can set returnsObjectsAsFaults to NO to gain a performance benefit if you know you will need to access the
             property values from the returned objects.

             By default, when you execute a fetch returnsObjectsAsFaults is YES; Core Data fetches the object data for the matching records, fills the
             row cache with the information, and returns managed object as faults. These faults are managed objects, but all of their property data
             resides in the row cache until the fault is fired. When the fault is fired, Core Data retrieves the data from the row cache. Although the
             overhead for this operation is small, for large datasets it may become non-trivial. If you need to access the property values from the
             returned objects (for example, if you iterate over all the objects to calculate the average value of a particular attribute), then it is
             more efficient to set returnsObjectsAsFaults to NO to avoid the additional overhead.
             */
            if (returnsObjectsAsFaults) {
                if (![object isFault]) {
                    // Make it a fault
                    [context refreshObject: object mergeChanges: NO];
                }
            } else {
                //
                // NOTE: All fetch settings in this ELSE seem to only
                //       make sense if returnsObjectAsFaults is NO.
                //
                if ([object isFault]) {
                    //
                    // Note that this actually fires the fault and makes another
                    // callback to newValuesForObjectWithID:withContext:error:.
                    //
                    // This is the only way I know to force the fault to fire.
                    // Settings the values from
                    //
                    [object willAccessValueForKey: nil];

                } else if (shouldRefreshRefetchedObjects) {
                    /*
                     - shouldRefreshRefetchedObjects

                     Sets whether the fetch request should cause property values of fetched objects to be updated with the current values in the persistent store.

                     YES if the fetch request should cause property values of fetched objects to be updated with the current values in the persistent store, otherwise NO.

                     By default, when you fetch objects they maintain their current property values, even if the values in the persistent store have changed. By invoking
                     this method with the parameter YES, when the fetch is executed the property values of fetched objects to be updated with the current values in the
                     persistent store. This provides more convenient way to ensure managed object property values are consistent with the store than by
                     using refreshObject:mergeChanges: (NSManagedObjetContext) for multiple objects in turn.
                     */
                    [context refreshObject: object mergeChanges: YES];
                }
            }
        }
        return result;
    }

    - (id) managedObjectIDResultFromWorkingSet: (NSArray *) workingSet forFetchRequest: (NSFetchRequest *)request context: (NSManagedObjectContext *) context error:(NSError *__autoreleasing *)error {

        NSMutableArray * result = [[NSMutableArray alloc] initWithCapacity: [workingSet count]];

        for (MGInMemoryReferenceObject * referenceObject in workingSet) {
            [result addObject: [referenceObject objectID]];
        }

        return result;
    }

    /*
     These are specific to the Dictionary return type

     Managing How Results Are Returned

     – propertiesToFetch                    - Implemented
     – returnsDistinctResults               - Implemented (not fully functional yet)

     Grouping and Filtering Dictionary Results

     – propertiesToGroupBy
     – havingPredicate

     */
    - (id) dictionaryResultFromWorkingSet: (NSArray *) workingSet forFetchRequest: (NSFetchRequest *)request context: (NSManagedObjectContext *) context error:(NSError *__autoreleasing *)error {

        id        result     = nil;
        NSArray * properties = nil;

        /*
         – returnsDistinctResults

             Determines whether the request should return only distinct values for the fields specified by propertiesToFetch.
             If YES, the request returns only distinct values for the fields specified by propertiesToFetch.
         */
        if ([request returnsDistinctResults]) {
            result = [[NSMutableSet alloc] initWithCapacity: [workingSet count]];

#warning A custom sublcass of NSDictionary needs to be created to add to the set in order for returnsDistinctResults to work with this set.
            if (error) {
                *error = [NSError errorWithDomain: @"MGMemoryPersistentStoreErrorDomain" code: 1200 userInfo: @{NSLocalizedDescriptionKey: [NSString stringWithFormat: @"Store type %@ does not suppert fetch request property %@", NSStringFromClass([self class]), @"returnsDistinctResults"]}];
                return nil;
            }

        } else {
            result = [[NSMutableArray alloc] initWithCapacity: [workingSet count]];
        }

        /*
         – propertiesToGroupBy

             If you use this setting, then you must set the resultType to NSDictionaryResultType,
             and the SELECT values must be literals, aggregates, or columns specified in the GROUP BY.
             Aggregates will operate on the groups specified in the GROUP BY rather than the whole table.
             If you set properties to group by, you can also set a having predicate—see setHavingPredicate:.
         */
        if ([request propertiesToGroupBy]) { // Not implemented yet

            /*
             – havingPredicate

                 Sets the predicate to use to filter rows being returned by a query containing a GROUP BY.

                 The predicate to use to filter rows being returned by a query containing a GROUP BY.

                 If a having predicate is supplied, it will be run after the GROUP BY. Specifying a HAVING predicate
                 requires that a GROUP BY also be specified. For a discussion of GROUP BY, see setPropertiesToGroupBy:.
             */
            if ([request havingPredicate]) { // Not implemented yet

            }
        }

        /*
         – propertiesToFetch

             The property descriptions may represent attributes, to-one relationships, or expressions. The name of an attribute
             or relationship description must match the name of a description on the fetch request’s entity.

             This value is only used if resultType is set to NSDictionaryResultType.
         */
        if ([request propertiesToFetch]) {
            //
            // Note: NSFetchRequest verifies the parameters are correct
            //       and that we only get the proper types of attribtues
            //       here so we can safely just take the list as is.
            //
            properties = [request propertiesToFetch];
        } else {
            //
            // The property descriptions that represent attributes and to-one relationships
            //
            NSMutableArray * filteredProperties = [[NSMutableArray alloc] init];

            for (id property in [[request entity] properties]) {
                //
                // We have to filter out toMany relationships as they are not supported
                // dfor dictionary result types
                //
                if ([property isMemberOfClass: [NSRelationshipDescription class]]) {
                    if (![property isToMany]) {
                        [filteredProperties addObject: property];
                    }
                } else {
                    [filteredProperties addObject: property];
                }
            }
            properties = filteredProperties;
        }

        //
        // Process the working set for the properties
        // calculated above.
        //
        for (MGInMemoryReferenceObject * referenceObject in workingSet) {
            NSMutableDictionary * dictionary = [[NSMutableDictionary alloc] initWithCapacity: [properties count]];
            [result addObject: dictionary];

            for (id property in properties) {
                NSString * propertyName = [property name];

                if ([property isKindOfClass: [NSAttributeDescription class]]) {
                    //
                    // Attributes are simply copied
                    //
                    [dictionary setObject: [referenceObject primitiveValueForKey: propertyName] forKey: propertyName];

                } else if ([property isKindOfClass: [NSRelationshipDescription class]]) {
                    //
                    // Relationships are faulted in or null
                    //
                    id relatedObjectID = [[referenceObject primitiveValueForKey: propertyName] objectID];

                    if (!relatedObjectID) {
                        relatedObjectID = [NSNull null];
                    }
                    [dictionary setValue: relatedObjectID forKey: propertyName];

                } else {
                    /*
                     Its an expression.

                     These are going to be very difficult to evaluate in the in memory. Mainly because
                     they may be an aggragate or a per object expression.


                     Here's an example of an aggragate expression:

                        // Specify that the request should return dictionaries.
                        [request setResultType:NSDictionaryResultType];

                        // Create an expression for the key path.
                        NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"sequenceNumber"];

                        // Create an expression to represent the maximum value at the key path 'creationDate'
                        NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];

                        // Create an expression description using the maxExpression and returning a date.
                        NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];

                        // The name is the key that will be used in the dictionary for the return value.
                        [expressionDescription setName:@"maxSequenceNumber"];
                        [expressionDescription setExpression:maxExpression];
                        [expressionDescription setExpressionResultType:NSInteger32AttributeType];

                        // Set the request's properties to fetch just the property represented by the expressions.
                        [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];

                     */
#warning Need to implement NSExpressionDescription type on NSDictionaryResultTypes
                    if (error) {
                        *error = [NSError errorWithDomain: @"MGMemoryPersistentStoreErrorDomain" code: 1200 userInfo: @{NSLocalizedDescriptionKey: [NSString stringWithFormat: @"Store type %@ does not suppert fetch request with %@", NSStringFromClass([self class]), @"NSExpressionDescriptions"]}];
                        return nil;
                    }

                }
            }
        }
        return result;
    }

    /*
        This one is very simple since we only need the result count
     */
    - (id) countResultFromWorkingSet: (NSArray *) workingSet forFetchRequest: (NSFetchRequest *)request context: (NSManagedObjectContext *) context error:(NSError *__autoreleasing *)error {
        return [[NSArray alloc] initWithObjects:[NSNumber numberWithUnsignedInteger: [workingSet count]], nil];
    }

    - (NSIncrementalStoreNode *) newValuesForObjectWithID:(NSManagedObjectID *)objectID withContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error  {

        NSParameterAssert(objectID != nil);
        NSParameterAssert(context != nil);

        id result = nil;

        @synchronized(cache) {

            MGInMemoryReferenceObject * referenceObject = [self referenceObjectWithObjectID: objectID];
            result = [[NSIncrementalStoreNode alloc] initWithObjectID: objectID withValues: [referenceObject attributeValuesAndKeys] version: [referenceObject version]];
        }
        return result;
    }

    - (id)newValueForRelationship:(NSRelationshipDescription *)relationship forObjectWithID:(NSManagedObjectID *)objectID withContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error {

        NSParameterAssert(relationship != nil);
        NSParameterAssert(objectID != nil);
        NSParameterAssert(context != nil);

        id result = nil;

        @synchronized(cache) {

            MGInMemoryReferenceObject * referenceObject   = [self referenceObjectWithObjectID: objectID];
            result = [referenceObject relationshipFaultValue: relationship];
        }
        return result;
    }

#pragma mark - Private methods

    - (MGInMemoryReferenceObject *) referenceObjectWithObjectID: (NSManagedObjectID *) objectID {

        NSParameterAssert(objectID != nil);

        NSMutableDictionary * entityReferenceObjects = [cache objectForKey: [[objectID entity] name]];

        return [entityReferenceObjects objectForKey: objectID];
    }

@end