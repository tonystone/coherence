//
//  MGLogWriter.m
//  Connect
//
//  Created by Tony Stone on 5/7/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGLogWriter.h"
#import "MGTransactionLogRecord.h"
#import "MGRuntimeException.h"
#import "MGMetadataManager.h"
#import "MGConnectManagedObjectContext+Internal.h"
#import "MGConnectPersistentStoreCoordinator+Internal.h"

#import "MGEntitySettings.h"
#import "MGManagedEntity.h"

#import <CoreData/CoreData.h>

/**
   MGLogWriter

    Note: This file specifically uses returned errors for most cases
          so that it follows the expected behavior for CoreData classes.
*/
@implementation MGLogWriter {
    NSManagedObjectContext * logContext;
    MGMetadataManager      * metadataManager;
}

- (id) initWithManagedObjectContext:(NSManagedObjectContext *)aLogContext metadataManager: (MGMetadataManager *) aMetadataManager {
    
    if ((self = [super init])) {
        logContext      = aLogContext;
        metadataManager = aMetadataManager;
    }
    return self;
}

- (MGTransactionID *) logTransactionForContextChanges: (MGConnectManagedObjectContext *) aChangeContext {
    
    NSAssert([[aChangeContext persistentStoreCoordinator] isKindOfClass: [MGConnectPersistentStoreCoordinator class]],  @"");
    
    MGConnectPersistentStoreCoordinator * persistentStoreCoordinator = (MGConnectPersistentStoreCoordinator *)[aChangeContext persistentStoreCoordinator];
    
    //
    // NOTE: This method must be reentrent.  Be sure to use only stack variables asside from
    //       the protected access method nextSequenceNumberBlock
    //
    NSSet * inserted = [aChangeContext insertedObjects];
    NSSet * updated  = [aChangeContext updatedObjects];
    NSSet * deleted  = [aChangeContext deletedObjects];
    
    //
    // Get a block of sequence numbers to use for the records
    // that need recording.
    //
    // Sequence number = begin + end + inserted + updated + deleted
    //
    NSUInteger sequenceNumberBlockSize = 2 + [inserted count] + [updated count] + [deleted count];
    NSUInteger sequenceNumberBlock     = [metadataManager nextSequenceNumberBlock: sequenceNumberBlockSize];
    
    [logContext setMergePolicy: NSMergeByPropertyObjectTrumpMergePolicy];
    
    MGTransactionID * transactionID = [self logBeginTransactionRecord: logContext sequenceNumberBlock: &sequenceNumberBlock];
    
    [self  logInsertRecords: inserted forTransaction: transactionID sequenceNumberBlock: &sequenceNumberBlock persistentStoreCoordinator: persistentStoreCoordinator metadataContext: logContext];
    [self  logUpdateRecords: updated  forTransaction: transactionID sequenceNumberBlock: &sequenceNumberBlock persistentStoreCoordinator: persistentStoreCoordinator metadataContext: logContext];
    [self  logDeleteRecords: deleted  forTransaction: transactionID sequenceNumberBlock: &sequenceNumberBlock persistentStoreCoordinator: persistentStoreCoordinator metadataContext: logContext];
    
    [self logEndTransactionRecord: transactionID metadataContext: logContext sequenceNumberBlock: &sequenceNumberBlock];
    
    //
    // If we only have the begin and end markers
    // then there were no entities in the transaction
    // that were loggable.
    //
    if ([[logContext insertedObjects] count] == 2) {
        
        [logContext rollback];
        transactionID = nil;
        
    } else {
        NSError * error = nil;
        
        if (![logContext save: &error]) {
            @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [error localizedDescription] userInfo: @{@"error": error}];
        }
    }
    return transactionID;
}

- (void) removeTransaction: (MGTransactionID *) aTransactionID {

    NSError * error = nil;
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
	[fetchRequest    setEntity: [NSEntityDescription entityForName: @"MGTransactionLogRecord" inManagedObjectContext: logContext]];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"transactionID==%@", aTransactionID]];
    
    NSMutableArray * transactionLogRecords = [NSMutableArray arrayWithArray:[logContext executeFetchRequest: fetchRequest error: &error]];
    
    if (error) {
        @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [error localizedDescription] userInfo: @{@"error": error}];
    }
    
    for (NSManagedObject * managedObject in transactionLogRecords) {
        [logContext deleteObject: managedObject];
    }

    if (![logContext save: &error]) {
        @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [error localizedDescription] userInfo: @{@"error": error}];
                
    }
}

#pragma mark - Internal Private methods

- (MGTransactionID *) logBeginTransactionRecord: (NSManagedObjectContext *) metadataContext sequenceNumberBlock: (NSUInteger *) sequenceNumberBlock {
    MGTransactionID * transactionID  = nil;
    
    MGTransactionLogRecord * transactionLogRecord = (MGTransactionLogRecord *) [NSEntityDescription insertNewObjectForEntityForName: @"MGTransactionLogRecord" inManagedObjectContext: metadataContext];
    
    NSError * error = nil;
    
    if (![metadataContext obtainPermanentIDsForObjects: @[transactionLogRecord] error: &error]) {
        @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [NSString stringWithFormat: @"Failed to obtain perminent id for transaction log record: %@", [error localizedFailureReason]] userInfo: @{@"error": error}];
    }
    
    //
    // We use the URI representation of the object id as the transactionID
    //
    transactionID = [[[transactionLogRecord objectID] URIRepresentation] absoluteString];
    
    [transactionLogRecord setTransactionID:          transactionID];
    [transactionLogRecord setSequenceNumber:         [NSNumber numberWithUnsignedInteger: *sequenceNumberBlock]];
    [transactionLogRecord setPreviousSequenceNumber: [NSNumber numberWithUnsignedInteger: *sequenceNumberBlock - 1]];
    [transactionLogRecord setType:                   [NSNumber numberWithInt: MGTransactionLogRecordTypeBeginMarker]];
    [transactionLogRecord setTimestamp:              [NSDate date]];
    
    //
    // Increment the sequence for this record
    //
    (*sequenceNumberBlock)++;
    
    return transactionID;
}

- (void) logEndTransactionRecord: (MGTransactionID *) transactionID metadataContext: (NSManagedObjectContext *) metadataContext sequenceNumberBlock: (NSUInteger *) sequenceNumberBlock {
    
    MGTransactionLogRecord * transactionLogRecord = (MGTransactionLogRecord *) [NSEntityDescription insertNewObjectForEntityForName: @"MGTransactionLogRecord" inManagedObjectContext: metadataContext];
    
    [transactionLogRecord setTransactionID:          transactionID];
    [transactionLogRecord setSequenceNumber:         [NSNumber numberWithUnsignedInteger: *sequenceNumberBlock]];
    [transactionLogRecord setPreviousSequenceNumber: [NSNumber numberWithUnsignedInteger: *sequenceNumberBlock - 1]];
    [transactionLogRecord setType:                   [NSNumber numberWithInt: MGTransactionLogRecordTypeEndMarker]];
    [transactionLogRecord setTimestamp:              [NSDate date]];
    
    //
    // Increment the sequence for this record
    //
    (*sequenceNumberBlock)++;
}

- (void) logInsertRecords: (NSSet *) insertedRecords forTransaction: (MGTransactionID *) transactionID sequenceNumberBlock: (NSUInteger *) sequenceNumberBlock persistentStoreCoordinator: (MGConnectPersistentStoreCoordinator *) persistentStoreCoordinator metadataContext: (NSManagedObjectContext *) metadataContext {
    
    for (NSManagedObject * object in insertedRecords) {
        
        MGTransactionLogRecord * transactionLogRecord = [self transactionLogRecord: MGTransactionLogRecordTypeDelete object: object transaction: transactionID sequenceNumber: *sequenceNumberBlock persistentStoreCoordinator: persistentStoreCoordinator metadataContext: metadataContext];
        
        if (transactionLogRecord) {
            //
            // Get the object attribute change data
            //
            MGTransactionLogRecordInsertData * data = [[MGTransactionLogRecordInsertData alloc] init];
            
            data->attributesAndValues = [object dictionaryWithValuesForKeys: [[[object entity] attributesByName] allKeys]];
            
            [transactionLogRecord setUpdatedObjectData: data];
            
            //
            // Increment the sequence for this record
            //
            (*sequenceNumberBlock)++;
        }
    }
}

- (void) logUpdateRecords: (NSSet *) updatedRecords forTransaction: (MGTransactionID *) transactionID sequenceNumberBlock: (NSUInteger *) sequenceNumberBlock persistentStoreCoordinator: (MGConnectPersistentStoreCoordinator *) persistentStoreCoordinator metadataContext: (NSManagedObjectContext *) metadataContext {
    
    for (NSManagedObject * object in updatedRecords) {
        
        MGTransactionLogRecord * transactionLogRecord = [self transactionLogRecord: MGTransactionLogRecordTypeDelete object: object transaction: transactionID sequenceNumber: *sequenceNumberBlock persistentStoreCoordinator: persistentStoreCoordinator metadataContext: metadataContext];
        
        if (transactionLogRecord) {
            //
            // Get the object attribute change data
            //
            MGTransactionLogRecordUpdateData * data = [[MGTransactionLogRecordUpdateData alloc] init];
            
            data->attributesAndValues = [object dictionaryWithValuesForKeys: [[[object entity] attributesByName] allKeys]];
            data->updatedAttributes   = [[object changedValues] allKeys];
            
            [transactionLogRecord setUpdatedObjectData: data];
            
            //
            // Increment the sequence for this record
            //
            (*sequenceNumberBlock)++;
        }
    }
}

- (void) logDeleteRecords: (NSSet *) deletedRecords forTransaction: (MGTransactionID *) transactionID sequenceNumberBlock: (NSUInteger *) sequenceNumberBlock persistentStoreCoordinator: (MGConnectPersistentStoreCoordinator *) persistentStoreCoordinator metadataContext: (NSManagedObjectContext *) metadataContext{
    
    for (NSManagedObject * object in deletedRecords) {
        
        MGTransactionLogRecord * transactionLogRecord = [self transactionLogRecord: MGTransactionLogRecordTypeDelete object: object transaction: transactionID sequenceNumber: *sequenceNumberBlock persistentStoreCoordinator: persistentStoreCoordinator metadataContext: metadataContext];
        
        if (transactionLogRecord) {
            //
            // Increment the sequence for this record
            //
            (*sequenceNumberBlock)++;
        }
    }
}

- (MGTransactionLogRecord *) transactionLogRecord: (MGTransactionLogRecordType) logRecordType object: (NSManagedObject *) object transaction: (MGTransactionID *) transactionID  sequenceNumber: (NSUInteger) sequenceNumber persistentStoreCoordinator: (MGConnectPersistentStoreCoordinator *) persistentStoreCoordinator metadataContext: (NSManagedObjectContext *) metadataContext {
   
    MGTransactionLogRecord * transactionLogRecord = nil;

    MGManagedEntity * managedEntity = [persistentStoreCoordinator managedEntity: [object entity]];
    
    if (managedEntity && [[object entity] logTransactions]) {
        
        transactionLogRecord = (MGTransactionLogRecord *) [NSEntityDescription insertNewObjectForEntityForName: @"MGTransactionLogRecord" inManagedObjectContext: metadataContext];
        
        [transactionLogRecord             setTransactionID: transactionID];
        [transactionLogRecord            setSequenceNumber: [NSNumber numberWithUnsignedInteger: sequenceNumber]];
        [transactionLogRecord    setPreviousSequenceNumber: [NSNumber numberWithUnsignedInteger: sequenceNumber - 1]];
        [transactionLogRecord                      setType: [NSNumber numberWithUnsignedInteger: logRecordType]];
        [transactionLogRecord                 setTimestamp: [NSDate date]];
        
        [transactionLogRecord setPersistentStoreIdentifier: [managedEntity persistentStoreIdentifier]];
        [transactionLogRecord                setEntityName: [[object entity] name]];
        [transactionLogRecord           setUpdatedObjectID: [[[object objectID] URIRepresentation] absoluteString]];
        
        //
        // Update the object identification data
        //
#warning FIXME - Code removed.
        NSArray * remoteIDAttributes = nil; // [[object entity] remoteIDAttributes];
        
        
        if ([remoteIDAttributes count]) {
            NSMutableString * updatedObjectUniqueID = [[NSMutableString alloc] init];
            
            for (id key in remoteIDAttributes) {
                [updatedObjectUniqueID appendFormat: @"%@", [object valueForKey: key]];
            }
            [transactionLogRecord setUpdatedObjectUniqueID: updatedObjectUniqueID];
        }
    }
    return transactionLogRecord;
}

@end
