//
//  MGDataMergeOperation.m
//  MGConnect
//
//  Created by Tony Stone on 4/16/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGDataMergeOperation.h"
#import <CoreData/CoreData.h>
#import "MGEntitySettings.h"
#import "MGManagedEntity.h"
#import "MGObjectMapper.h"
#import "MGMetadataManager.h"
#import "MGTransactionLogRecord.h"
#import "MGLogReader.h"
#import "MGRuntimeException.h"
#import "MGTraceLog.h"

@implementation MGDataMergeOperation

- (BOOL) mergeObjects: (NSArray *) sourceObjects managedEntity: (MGManagedEntity *) managedEntity subFilter: (NSPredicate *) subFilter context:(NSManagedObjectContext *) mergeContext error:(NSError **)error {
    
    // Required parameters
    NSParameterAssert(sourceObjects != nil);
    NSParameterAssert(managedEntity != nil);
    NSParameterAssert(mergeContext != nil);
    
    BOOL success = NO;
    
    NSEntityDescription * entity = [managedEntity entity];
    
#warning FIXME - Code Removed.
    NSArray             * keys   = nil; // [entity remoteIDAttributes];
    
    //
    // Create the sort descriptors for both
    // the source and target.
    //
    NSMutableArray * sortDescriptors = nil;
    
    if ([keys count]) {
        sortDescriptors = [[NSMutableArray alloc] init];
        
        for (NSString * key in keys) {
            [sortDescriptors addObject: [[NSSortDescriptor alloc] initWithKey: key ascending:YES]];
        }
    }

    //
    // Create the comparator to compare the source and target keys.
    //
    NSComparator comparator = ^NSComparisonResult (id obj1, id obj2) {
        
        NSComparisonResult comparisonResult = NSOrderedSame;
        
        for (NSString * key in keys) {
            comparisonResult = [[obj1 valueForKey: key] compare: [obj2 valueForKey: key]];
            
            // First non same value, break and return the result
            //
            // Note: if all keys are the same, we simply
            //       exit the loop with the NSOrderedSame value.
            //
            if (comparisonResult != NSOrderedSame) {
                break;
            }
        }
        return comparisonResult;
    };
    
    //
    // Create a block to create the primary key to seach the transaction log
    //
    id (^objectPrimaryKey)(id) = ^(id obj){
        
        NSMutableString * primaryKey = [[NSMutableString alloc] init];
        
        for (NSString * key in keys) {
            [primaryKey appendFormat: @"%@", [obj valueForKey: key]];
        }
        return primaryKey;
    };
    
    MGLogReader * logReader  = [[MGMetadataManager sharedManager] logReader];
    
    //
    // Get a list of exceptions for the merge from the transaction log
    //
    NSMutableDictionary * transactionsForEntity = [[NSMutableDictionary alloc] init];
    
    // Get the entities as managed objects
    NSArray * transactionLogRecords = [logReader transactionLogRecordsForManagedEntity: managedEntity];
    
    for (MGTransactionLogRecord * transactionLogRecord in transactionLogRecords) {
        MGTransactionLogRecordType type = [[transactionLogRecord type] integerValue];
        
        if (type == MGTransactionLogRecordTypeInsert ||
            type == MGTransactionLogRecordTypeUpdate ||
            type == MGTransactionLogRecordTypeDelete)
        {
            id targetObjecUniqueID = [transactionLogRecord updatedObjectUniqueID];
            if (targetObjecUniqueID) {
                [transactionsForEntity setObject: transactionLogRecord forKey: targetObjecUniqueID];
            }
        }
    }
    
    //
    // Setup the merge
    //
	//
    // Get the target ManagedObejcts
	NSFetchRequest * targetFetchRequest = [[NSFetchRequest alloc] init];
    
	[targetFetchRequest          setEntity: entity];
    [targetFetchRequest       setPredicate: subFilter];
	[targetFetchRequest setSortDescriptors: sortDescriptors];
    // Force CoreData to return the full objects so they can be conpared.  There are bugs with allowing it to fire the fault itself so this is needed.
    [targetFetchRequest setReturnsObjectsAsFaults: NO];
    
    //
    // We need a list of source and target objects in the same sorted order
    //
    NSArray * sortedSourceObjects = [sourceObjects sortedArrayUsingDescriptors: sortDescriptors];
	NSArray * sortedTargetObjects = [mergeContext executeFetchRequest: targetFetchRequest error: error];

    //
    // If the targetFetchRequests gets an error it could return nil
    //
    if (sortedTargetObjects) {
        
        // Compare source identifiers with target identifiers
        NSEnumerator * sourceObjectIterator = [sortedSourceObjects objectEnumerator];
        NSEnumerator * targetObjectIterator = [sortedTargetObjects objectEnumerator];
        
        NSManagedObject * sourceObject = [sourceObjectIterator nextObject];
        NSManagedObject * targetObject = [targetObjectIterator nextObject];
        
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
                comparison = comparator(sourceObject, targetObject);
            }
        
            MGTransactionLogRecord * objectTransactionLogRecord = [transactionsForEntity objectForKey: objectPrimaryKey(targetObject)];
            
            if (comparison == NSOrderedSame) {
                //
                // UPDATE: Identifiers match
                //
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
                    NSDictionary * sourceObjectValuesAndKeys = [sourceObject dictionaryWithValuesForKeys: [[entity attributesByName] allKeys]];
                    
                    [targetObject setValuesForKeysWithDictionary: sourceObjectValuesAndKeys];
                }
            
                // Move ahead in both lists
                sourceObject  = [sourceObjectIterator  nextObject];
                targetObject  = [targetObjectIterator  nextObject];
                
            } else if (comparison == NSOrderedAscending) {
                //
                // INSERT: Imported item sorts before stored item
                //
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
                    NSManagedObject * newObject = [NSEntityDescription insertNewObjectForEntityForName: [entity name] inManagedObjectContext: mergeContext];
                    
                    NSDictionary * sourceObjectValuesAndKeys = [sourceObject dictionaryWithValuesForKeys: [[entity attributesByName] allKeys]];
                    
                    [newObject setValuesForKeysWithDictionary: sourceObjectValuesAndKeys];
                }
                
                // Move ahead on the source
                sourceObject = [sourceObjectIterator nextObject];
                
            } else {
                //
                // DELETE: Imported item sorts after stored item
                //
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
           
                // Move ahead on the target
                targetObject  = [targetObjectIterator nextObject];
            }
        }
        
        // Only save this if there are actually changes that took place
        if ([mergeContext hasChanges]) {
            
            NSError * error = nil;
            
            if ([mergeContext save:&error]) {
                success = YES;
            } else {
                @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [NSString stringWithFormat: @"Failed to save context during merge operation.  Error: %@", [error localizedDescription]] userInfo: nil];
            }
        }
    }
    
    return success;
}

@end

