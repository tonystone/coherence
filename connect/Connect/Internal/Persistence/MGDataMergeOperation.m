//
//  MGDataMergeOperation.m
//  MGConnect
//
//  Created by Tony Stone on 4/16/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGDataMergeOperation.h"
#import <CoreData/CoreData.h>
#import "MGConnect+PrivateSettings.h"
#import "MGObjectMapper.h"
#import "MGTransactionLogRecord.h"
#import "MGTransactionLogManager.h"
#import "MGLoggedManagedObjectContext.h"
#import "MGRuntimeException.h"
#import "MGTraceLog.h"

@implementation MGDataMergeOperation {
    NSArray      * sourceSortDescriptors;
    NSArray      * targetSortDescriptors;
    NSComparator   objectComparator;
    NSString     * objectUniqueIDAttribute;
}

- (NSString *) description {
    return [NSString stringWithFormat: @"<%@ : %p>\r{\rSource sort descriptors: %@\rTarget sort descriptors: %@\rComparator: %@\rObject unique ID Attribute: %@\r}\r", NSStringFromClass([self class]), self, sourceSortDescriptors, targetSortDescriptors, objectComparator, objectUniqueIDAttribute];
}

- (BOOL) mergeObjects: (NSArray *) sourceObjects entity: (NSEntityDescription *) anEntity subFilter: (NSPredicate *) aSubfilter context:(MGLoggedManagedObjectContext *) mergeContext error:(NSError **)error {
    BOOL success = NO;
    
    MGTransactionLogManager   * transactionLogManager  = [mergeContext transactionLogManager];
    NSManagedObjectContext    * transactionLogContext  = [transactionLogManager transactionLogEditContext];
    
    //
    // Get a list of exceptions for the merge from the transaction log
    //
    NSMutableDictionary * transactionsForEntity = [[NSMutableDictionary alloc] init];
    
    // Get the entities as managed objects
    NSArray * transactionLogRecords = [transactionLogManager transactionLogRecordsForEntity: anEntity inContext:transactionLogContext];
    
    for (MGTransactionLogRecord * transactionLogRecord in transactionLogRecords) {
        MGTransactionLogRecordType type = [[transactionLogRecord type] integerValue];
        
        if (type == MGTransactionLogRecordTypeInsert ||
            type == MGTransactionLogRecordTypeUpdate ||
            type == MGTransactionLogRecordTypeDelete)
        {
            [transactionsForEntity setObject: transactionLogRecord forKey: [transactionLogRecord updateUniqueID]];
        }
    }
    
    //
    // Setup the merge
    //
	//
    // Get the target ManagedObejcts
	NSFetchRequest * targetFetchRequest = [[NSFetchRequest alloc] init];
    
	[targetFetchRequest          setEntity: anEntity];
    [targetFetchRequest       setPredicate: aSubfilter];
	[targetFetchRequest setSortDescriptors: targetSortDescriptors];
	
    //
    // We need a list of source and target objects in the same sorted order
    //
    NSArray * sortedSourceObjects = [sourceObjects sortedArrayUsingDescriptors: sourceSortDescriptors];
	NSArray * sortedTargetObjects = [mergeContext executeFetchRequest: targetFetchRequest error: error];

    //
    // If the targetFetchRequests gets an error it could return nil
    //
    if (sortedTargetObjects) {
        
        // Compare source identifiers with target identifiers
        NSEnumerator * sourceObjectIterator = [sortedSourceObjects objectEnumerator];
        NSEnumerator * targetObjectIterator = [sortedTargetObjects  objectEnumerator];
        
        NSDictionary    * sourceObject = [sourceObjectIterator nextObject];
        NSManagedObject * targetObject = [sourceObjectIterator nextObject];
        
        // Loop through both lists, comparing identifiers, until both are empty
        while (sourceObject || targetObject) {
            
            // Compare identifiers
            NSComparisonResult comparison;
            if (!sourceObject) {
                // If the source key list has run out, the source aKey sorts last (i.e. remove remaining source objects)
                comparison = NSOrderedDescending;
            } else if (!targetObject) {
                // If target list has run out, the import aKey sorts first (i.e. add remaining source objects)
                comparison = NSOrderedAscending;
            } else {
                // If neither list has run out, compare with the object
                comparison = objectComparator(sourceObject, targetObject);
            }
            
            if (comparison == NSOrderedSame) {
                // UPDATE: Identifiers match
        
                MGTransactionLogRecord * objectTransactionLogRecord = [transactionsForEntity objectForKey: [targetObject valueForKey: objectUniqueIDAttribute]];
                
                if (objectTransactionLogRecord) {
                    //
                    // Note: LOCAL UPDATE: Only update the local copy if our local copy has not been changed
                    //                     This will preserve the transactiopn log and allow it to update the
                    //                     server later
                    //
                    // ------------------------------------------------------------------------------------------
                    //
                    //       LOCAL DELETE: A local delete would never match a key in the database, instead, this would
                    //                     show up as an insert
                    //
                    //       LOCAL INSERT: An insert on our side would never match the resource reference on this side
                    //
                    if ([[objectTransactionLogRecord type] unsignedIntegerValue] == MGTransactionLogRecordTypeUpdate) {
                        ;   // We assume that once we update the server with our local update, the condition below
                            // will com into affect and the values will merged.
                    }
                } else {
                    NSDictionary * sourceObjectValuesAndKeys = [sourceObject dictionaryWithValuesForKeys: [[anEntity attributesByName] allKeys]];
                    
                    [targetObject setValuesForKeysWithDictionary: sourceObjectValuesAndKeys];
                }
            
                // Move ahead in both lists
                sourceObject  = [sourceObjectIterator  nextObject];
                targetObject  = [targetObjectIterator  nextObject];
                
            } else if (comparison == NSOrderedAscending) {
                //
                // INSERT: Imported item sorts before stored item
                //
                
                MGTransactionLogRecord * objectTransactionLogRecord = [transactionsForEntity objectForKey: [targetObject valueForKey: objectUniqueIDAttribute]];
                
                if (objectTransactionLogRecord) {
                    //
                    // Note: LOCAL DELETE: A local  deleted record is the only condition that we
                    //                     care about here and need to deal with.  In this case the
                    //                     record is not in our local cache but has not yet been deleted
                    //                     from the server.  It still remains in our transaction log though
                    //
                    // ------------------------------------------------------------------------------------------
                    //
                    //       LOCAL UPDATE: A record that has been updated locally would not match the resource
                    //                     reference of a record from the server we consider new
                    //
                    //       LOCAL INSERT: An insert on our side would never match the resource reference
                    //                     of a server inserted record  so we let the new record be inserted
                    //
                    if ([[objectTransactionLogRecord type] unsignedIntegerValue] == MGTransactionLogRecordTypeDelete) {
                        ;   // The object on the server has been deleted locally and has not yet updated the server
                            // We do not need to deal with this here.  The server will be updated in time
                    }
                } else {
                    NSManagedObject * newObject = [NSEntityDescription insertNewObjectForEntityForName: [anEntity name] inManagedObjectContext: mergeContext];
                    
                    NSDictionary * sourceObjectValuesAndKeys = [sourceObject dictionaryWithValuesForKeys: [[anEntity attributesByName] allKeys]];
                    
                    [newObject setValuesForKeysWithDictionary: sourceObjectValuesAndKeys];
                }
                
                sourceObject = [sourceObjectIterator  nextObject];
                
            } else {
                //
                // DELETE: Imported item sorts after stored item
                //

                MGTransactionLogRecord * objectTransactionLogRecord = [transactionsForEntity objectForKey: [targetObject valueForKey: objectUniqueIDAttribute]];
                
                if (objectTransactionLogRecord) {
                    //
                    // Note: LOCAL UPDATE: A local update to a deleted record is the only condition that we
                    //                     care about here and need to deal with.
                    //
                    // ------------------------------------------------------------------------------------------
                    //
                    //       LOCAL DELETE: A delete on both sides requires no action here because it is
                    //                     already removed from our local cache
                    //
                    //       LOCAL INSERT: An insert on our side would never match the resource reference on this side
                    //
                    if ([[objectTransactionLogRecord type] unsignedIntegerValue] == MGTransactionLogRecordTypeUpdate) {
                        ;   // Merge conflict, we need to store the fact and notify the user that this object
                            // has been removed
                    }
                } else {
                    // The stored item is not among those imported, and should be removed, then move ahead to the next stored item
                    [mergeContext deleteObject: targetObject];
                }
           
                // Move ahead on the objects
                targetObject  = [targetObjectIterator nextObject];
            }
        }
        
        // Only save this if there are actually changes that took place
        if ([mergeContext hasChanges]) {
            
            NSError * error = nil;
            
            if ([mergeContext save:&error logChanges: NO]) {
                success = YES;
            } else {
                @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [NSString stringWithFormat: @"Failed to save context during merge operation.  Error: %@", [error localizedFailureReason]] userInfo: nil];
            }
        }
    }
    
    return success;
}

@end

@implementation MGDataMergeOperation (Initialization)

- (id) init {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (id) initWithSourceSortDescriptors: (NSArray *) theSourceSortDescriptors targetSortDescriptors: (NSArray *) theTargetSortDescriptors objectComparator: (NSComparator) aComparator objectUniqueIDAttribute: (NSString *) anObjectUniqueIDAttribute {
 
    NSParameterAssert(theSourceSortDescriptors);
    NSParameterAssert(theTargetSortDescriptors);
    NSParameterAssert(aComparator);
    NSParameterAssert(anObjectUniqueIDAttribute != nil);
    
    LogTrace(1, @"Initializing...");
    
    if ((self = [super init])) {
        sourceSortDescriptors   = theSourceSortDescriptors;
        targetSortDescriptors   = theTargetSortDescriptors;
        objectComparator        = aComparator;
        objectUniqueIDAttribute = anObjectUniqueIDAttribute;
    }
    
    LogTrace(1, @"Initialized");
    
    return self;
}

@end
