//
//  MGTransactionLogManager.m
//  MGConnect
//
//  Created by Tony Stone on 4/17/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGTransactionLogManager.h"
#import "MGBackingStore.h"
#import <CoreData/CoreData.h>
#import "MGRuntimeException.h"

@implementation MGTransactionLogManager {
    MGBackingStore * metadataStore;
    
    NSUInteger nextSequenceNumber;
}

- (NSManagedObjectContext *) transactionLogEditContext {
    NSManagedObjectContext * aContext = [[NSManagedObjectContext alloc] init];
    [aContext setPersistentStoreCoordinator: [metadataStore persistentStoreCoordinator]];
    return aContext;
}

- (NSUInteger) nextSequenceNumberBlock: (NSUInteger) size {
    @synchronized (self) {
        NSUInteger sequenceNumberBlockStart = nextSequenceNumber;
        
        nextSequenceNumber = nextSequenceNumber + size;
        
        return sequenceNumberBlockStart;
    }
}

- (MGTransactionID *) logTransactionForContextChanges: (NSManagedObjectContext *) transactionContext {
    
    //
    // NOTE: This method must be reentrent.  Be sure to use only stack variables asside from
    //       the protected access method nextSequenceNumberBlock
    //
    NSSet * inserted = [transactionContext insertedObjects];
    NSSet * updated  = [transactionContext updatedObjects];
    NSSet * deleted  = [transactionContext deletedObjects];
    
    //
    // Get a block of sequence numbers to use for the records
    // that need recording.
    //
    // Sequence number = begin + end + inserted + updated + deleted
    //
    NSUInteger sequenceNumberBlockSize = 2 + [inserted count] + [updated count] + [deleted count];
    NSUInteger sequenceNumberBlock     = [self nextSequenceNumberBlock: sequenceNumberBlockSize];
    
    //
    // Local metadataContext for this thread
    //
    NSManagedObjectContext * metadataContext = [self transactionLogEditContext];
    
    [metadataContext setMergePolicy: NSMergeByPropertyObjectTrumpMergePolicy];
    
    MGTransactionID * transactionID = [self logBeginTransactionRecord: metadataContext sequenceNumberBlock: &sequenceNumberBlock];

    [self  logInsertRecords: [transactionContext insertedObjects] forTransaction: transactionID metadataContext: metadataContext sequenceNumberBlock: &sequenceNumberBlock];
    [self  logUpdateRecords: [transactionContext  updatedObjects] forTransaction: transactionID metadataContext: metadataContext sequenceNumberBlock: &sequenceNumberBlock];
    [self  logDeleteRecords: [transactionContext  deletedObjects] forTransaction: transactionID metadataContext: metadataContext sequenceNumberBlock: &sequenceNumberBlock];

    [self logEndTransactionRecord: transactionID metadataContext: metadataContext sequenceNumberBlock: &sequenceNumberBlock];

    if ([metadataContext hasChanges]) {
        NSError * error = nil;
        
        if (![metadataContext save: &error]) {
            // Throw an exception
        }
    }
    return transactionID;
}

- (void) removeTransaction: (MGTransactionID *) aTransactionID {
    
}

- (NSArray *) transactionLogRecordsForTransaction: (MGTransactionID *) aTransactionID inContext: (NSManagedObjectContext *) aContext {
    return nil;
}

- (NSArray *) transactionLogRecordsForEntity: (NSEntityDescription *) anEntityDescription inContext: (NSManagedObjectContext *) aContext {
    
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
	[fetchRequest    setEntity: [NSEntityDescription entityForName: @"MGTransactionLogRecord" inManagedObjectContext: aContext]];
    [fetchRequest setPredicate: [NSPredicate   predicateWithFormat: @"updateEntityName == %@", [anEntityDescription name]]];
	
    NSError * error = nil;
    
    NSArray * fetchResults = [aContext executeFetchRequest: fetchRequest error: &error];
    
    if (error) {
        @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [error localizedFailureReason] userInfo: @{@"error": error}];
    }
    
    return fetchResults;
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
                
    [transactionLogRecord setTransactionID:  transactionID];
    [transactionLogRecord setSequenceNumber: [NSNumber numberWithUnsignedInteger: *sequenceNumberBlock]];
    [transactionLogRecord setSequenceNumber: [NSNumber numberWithUnsignedInteger: *sequenceNumberBlock - 1]];
    [transactionLogRecord setType:           [NSNumber numberWithInt: MGTransactionLogRecordTypeBeginMarker]];
    [transactionLogRecord setTimestamp:      [NSDate date]];
    
    //
    // Increment the sequence for this record
    //
    (*sequenceNumberBlock)++;
    
    return transactionID;
}

- (void) logEndTransactionRecord: (MGTransactionID *) transactionID metadataContext: (NSManagedObjectContext *) metadataContext sequenceNumberBlock: (NSUInteger *) sequenceNumberBlock {

    MGTransactionLogRecord * transactionLogRecord = (MGTransactionLogRecord *) [NSEntityDescription insertNewObjectForEntityForName: @"MGTransactionLogRecord" inManagedObjectContext: metadataContext];

    //
    // We use the URI representation of the object id as the transactionID
    //
    transactionID = [[[transactionLogRecord objectID] URIRepresentation] absoluteString];
    
    [transactionLogRecord setTransactionID:  transactionID];
    [transactionLogRecord setSequenceNumber: [NSNumber numberWithUnsignedInteger: *sequenceNumberBlock]];
    [transactionLogRecord setSequenceNumber: [NSNumber numberWithUnsignedInteger: *sequenceNumberBlock - 1]];
    [transactionLogRecord setType:           [NSNumber numberWithInt: MGTransactionLogRecordTypeEndMarker]];
    [transactionLogRecord setTimestamp:      [NSDate date]];
    
    //
    // Increment the sequence for this record
    //
    (*sequenceNumberBlock)++;
}

- (void) logInsertRecords: (NSSet *) insertedRecords forTransaction: (MGTransactionID *) transactionID metadataContext: (NSManagedObjectContext *) metadataContext sequenceNumberBlock: (NSUInteger *) sequenceNumberBlock {
      
    for (NSManagedObject * object in insertedRecords) {
        
        MGTransactionLogRecord * transactionLogRecord = [self transactionLogRecord: MGTransactionLogRecordTypeInsert object: object transaction: transactionID metadataContext: metadataContext sequenceNumber: *sequenceNumberBlock];
        //
        // Get the object attribute change data
        //
        MGTransactionLogRecordInsertData * data = [[MGTransactionLogRecordInsertData alloc] init];
        
        data->attributesAndValues = [object dictionaryWithValuesForKeys: [[[object entity] attributesByName] allKeys]];
        
        [transactionLogRecord setUpdateData: data];
        
        //
        // Increment the sequence for this record
        //
        (*sequenceNumberBlock)++;
    }
}

- (void) logUpdateRecords: (NSSet *) updatedRecords forTransaction: (MGTransactionID *) transactionID metadataContext: (NSManagedObjectContext *) metadataContext sequenceNumberBlock: (NSUInteger *) sequenceNumberBlock {
    
    for (NSManagedObject * object in updatedRecords) {

        MGTransactionLogRecord * transactionLogRecord = [self transactionLogRecord: MGTransactionLogRecordTypeUpdate object: object transaction: transactionID metadataContext: metadataContext sequenceNumber: *sequenceNumberBlock];
        //
        // Get the object attribute change data
        //
        MGTransactionLogRecordUpdateData * data = [[MGTransactionLogRecordUpdateData alloc] init];
        
        data->attributesAndValues = [object dictionaryWithValuesForKeys: [[[object entity] attributesByName] allKeys]];
        data->updatedAttributes   = [[object changedValues] allKeys];
        
        [transactionLogRecord setUpdateData: data];
        
        //
        // Increment the sequence for this record
        //
        (*sequenceNumberBlock)++;
    }
}

- (void) logDeleteRecords: (NSSet *) deletedRecords forTransaction: (MGTransactionID *) transactionID metadataContext: (NSManagedObjectContext *) metadataContext sequenceNumberBlock: (NSUInteger *) sequenceNumberBlock {
    
    for (NSManagedObject * object in deletedRecords) {
        
        (void) [self transactionLogRecord: MGTransactionLogRecordTypeDelete object: object transaction: transactionID metadataContext: metadataContext sequenceNumber: *sequenceNumberBlock];
        //
        // Increment the sequence for this record
        //
        (*sequenceNumberBlock)++;
    }
}

- (MGTransactionLogRecord *) transactionLogRecord: (MGTransactionLogRecordType) logRecordType object: (NSManagedObject *) object transaction: (MGTransactionID *) transactionID metadataContext: (NSManagedObjectContext *) metadataContext sequenceNumber: (NSUInteger) sequenceNumber {
   
    MGTransactionLogRecord * transactionLogRecord = (MGTransactionLogRecord *) [NSEntityDescription insertNewObjectForEntityForName: @"MGTransactionLogRecord" inManagedObjectContext: metadataContext];
    
    [transactionLogRecord setTransactionID:  transactionID];
    [transactionLogRecord setSequenceNumber: [NSNumber numberWithUnsignedInteger: sequenceNumber]];
    [transactionLogRecord setSequenceNumber: [NSNumber numberWithUnsignedInteger: sequenceNumber - 1]];
    [transactionLogRecord setType:           [NSNumber numberWithInt: logRecordType]];
    [transactionLogRecord setTimestamp:      [NSDate date]];
    //
    // Update the object identification data
    //
#warning [transactionLogRecord setUpdateUniqueID: <Need to determine Unique ID field>]
    [transactionLogRecord   setUpdateObjectID: [[[object objectID] URIRepresentation] absoluteString]];
    [transactionLogRecord setUpdateEntityName: [[object entity] name]];
    
    return transactionLogRecord;
}

@end

@implementation MGTransactionLogManager (Initialization)

- (id) initWithMetadataStore: (MGBackingStore *) aMetadataStore {
    
    NSParameterAssert(aMetadataStore != nil);
    
    if ((self = [super init])) {
        metadataStore = aMetadataStore;
        
        [self initializeSequenceNumberGenerator];
    }
    return self;
}

- (void) initializeSequenceNumberGenerator {
    @synchronized (self) {
        
#warning This should be gotten from a table stored in the DB so we have continues sequence numbering
        //
        // We need to find the last log entry and get it's
        // sequenceNumber value to calculate the next number
        // in the database.
        //
        NSManagedObjectContext * metadataContext = [self transactionLogEditContext];
        
        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MGTransactionLogRecord"];
        
        [fetchRequest setFetchLimit: 1];
        [fetchRequest  setSortDescriptors: @[[NSSortDescriptor sortDescriptorWithKey:@"sequenceNumber" ascending:NO]]];
        
        NSError *error = nil;
        
        MGTransactionLogRecord * lastLogRecord = [[metadataContext executeFetchRequest:fetchRequest error: &error] lastObject];
        
        if (lastLogRecord) {
            nextSequenceNumber = [[lastLogRecord sequenceNumber] unsignedIntegerValue] + 1;
        } else {
            nextSequenceNumber = 1;
        }
    }
}

@end
