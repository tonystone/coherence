//
// Created by Tony Stone on 4/30/15.
//

#import "CCWriteAheadLog.h"
#import "CCBackingStore.h"
#import "CCMetaLogEntry.h"

@interface CCWriteAheadLog (Initialization)
    - (void) initializeSequenceNumberGenerator;
@end

@implementation CCWriteAheadLog {
        CCBackingStore * metadataStore;

        NSUInteger nextSequenceNumber;
    }

    - (id) initWithMetadataStore: (CCBackingStore *) aMetadataStore {

        NSParameterAssert(aMetadataStore != nil);

        if ((self = [super init])) {
            metadataStore = aMetadataStore;

            [self initializeSequenceNumberGenerator];
        }
        return self;
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

    - (CCTransactionID *) logTransactionForContextChanges: (NSManagedObjectContext *) transactionContext {

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

        CCTransactionID * transactionID = [self logBeginTransactionEntry:metadataContext sequenceNumberBlock:&sequenceNumberBlock];

        [self logInsertEntry:[transactionContext insertedObjects] forTransaction:transactionID metadataContext:metadataContext sequenceNumberBlock:&sequenceNumberBlock];
        [self logUpdateEntry:[transactionContext updatedObjects] forTransaction:transactionID metadataContext:metadataContext sequenceNumberBlock:&sequenceNumberBlock];
        [self logDeleteEntry:[transactionContext deletedObjects] forTransaction:transactionID metadataContext:metadataContext sequenceNumberBlock:&sequenceNumberBlock];

        [self logEndTransactionEntry:transactionID metadataContext:metadataContext sequenceNumberBlock:&sequenceNumberBlock];

        if ([metadataContext hasChanges]) {
            NSError * error = nil;

            if (![metadataContext save: &error]) {
                // Throw an exception
            }
        }
        return transactionID;
    }

    - (void) removeTransaction: (CCTransactionID *) aTransactionID {

    }

    - (NSArray *) transactionLogEntriesForTransaction:(CCTransactionID *)aTransactionID inContext: (NSManagedObjectContext *) aContext {
        return nil;
    }

    - (NSArray *) transactionLogRecordsForEntity: (NSEntityDescription *) anEntityDescription inContext: (NSManagedObjectContext *) aContext {

        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];

        [fetchRequest    setEntity: [NSEntityDescription entityForName: @"CCMetaLogEntry" inManagedObjectContext: aContext]];
        [fetchRequest setPredicate: [NSPredicate   predicateWithFormat: @"updateEntityName == %@", [anEntityDescription name]]];

        NSError * error = nil;

        NSArray * fetchResults = [aContext executeFetchRequest: fetchRequest error: &error];

        if (error) {
            @throw [NSException exceptionWithName: @"Runtime Exception" reason: [error localizedFailureReason] userInfo: @{@"error": error}];
        }

        return fetchResults;
    }

#pragma mark - Internal Private methods

    - (CCTransactionID *) logBeginTransactionEntry:(NSManagedObjectContext *)metadataContext sequenceNumberBlock: (NSUInteger *) sequenceNumberBlock {
        CCTransactionID * transactionID  = nil;

        CCMetaLogEntry * metaLogEntry = (CCMetaLogEntry *) [NSEntityDescription insertNewObjectForEntityForName: @"CCMetaLogEntry" inManagedObjectContext: metadataContext];

        NSError * error = nil;

        if (![metadataContext obtainPermanentIDsForObjects: @[metaLogEntry] error: &error]) {
            @throw [NSException exceptionWithName: @"Runtime Exception" reason: [NSString stringWithFormat: @"Failed to obtain perminent id for transaction log record: %@", [error localizedFailureReason]] userInfo: @{@"error": error}];
        }

        //
        // We use the URI representation of the object id as the transactionID
        //
        transactionID = [[[metaLogEntry objectID] URIRepresentation] absoluteString];

        [metaLogEntry setTransactionID:transactionID];
        [metaLogEntry setSequenceNumber:@(*sequenceNumberBlock)];
        [metaLogEntry setSequenceNumber:@(*sequenceNumberBlock - 1)];
        [metaLogEntry setType: CCMetaLogEntryTypeBeginMarker];
        [metaLogEntry setTimestamp:[NSDate date]];

        //
        // Increment the sequence for this record
        //
        (*sequenceNumberBlock)++;

        return transactionID;
    }

    - (void) logEndTransactionEntry:(CCTransactionID *)transactionID metadataContext:(NSManagedObjectContext *)metadataContext sequenceNumberBlock: (NSUInteger *) sequenceNumberBlock {

        CCMetaLogEntry * metaLogEntry = (CCMetaLogEntry *) [NSEntityDescription insertNewObjectForEntityForName: @"CCMetaLogEntry" inManagedObjectContext: metadataContext];

        //
        // We use the URI representation of the object id as the transactionID
        //
        transactionID = [[[metaLogEntry objectID] URIRepresentation] absoluteString];

        [metaLogEntry setTransactionID:transactionID];
        [metaLogEntry setSequenceNumber:@(*sequenceNumberBlock)];
        [metaLogEntry setSequenceNumber:@(*sequenceNumberBlock - 1)];
        [metaLogEntry setType:CCMetaLogEntryTypeEndMarker];
        [metaLogEntry setTimestamp:[NSDate date]];

        //
        // Increment the sequence for this record
        //
        (*sequenceNumberBlock)++;
    }

    - (void) logInsertEntry:(NSSet *)insertedRecords forTransaction:(CCTransactionID *)transactionID metadataContext:(NSManagedObjectContext *)metadataContext sequenceNumberBlock: (NSUInteger *) sequenceNumberBlock {

        for (NSManagedObject * object in insertedRecords) {

            CCMetaLogEntry * metaLogEntry = [self transactionLogEntry:CCMetaLogEntryTypeInsert object:object transaction:transactionID metadataContext:metadataContext sequenceNumber:*sequenceNumberBlock];
            //
            // Get the object attribute change data
            //
            CCMetaLogEntryInsertData * data = [[CCMetaLogEntryInsertData alloc] init];

            data->attributesAndValues = [object dictionaryWithValuesForKeys: [[[object entity] attributesByName] allKeys]];

            [metaLogEntry setUpdateData:data];

            //
            // Increment the sequence for this record
            //
            (*sequenceNumberBlock)++;
        }
    }

    - (void) logUpdateEntry:(NSSet *)updatedRecords forTransaction:(CCTransactionID *)transactionID metadataContext:(NSManagedObjectContext *)metadataContext sequenceNumberBlock: (NSUInteger *) sequenceNumberBlock {

        for (NSManagedObject * object in updatedRecords) {

            CCMetaLogEntry * metaLogEntry = [self transactionLogEntry:CCMetaLogEntryTypeUpdate object:object transaction:transactionID metadataContext:metadataContext sequenceNumber:*sequenceNumberBlock];
            //
            // Get the object attribute change data
            //
            CCMetaLogEntryUpdateData * data = [[CCMetaLogEntryUpdateData alloc] init];

            data->attributesAndValues = [object dictionaryWithValuesForKeys: [[[object entity] attributesByName] allKeys]];
            data->updatedAttributes   = [[object changedValues] allKeys];

            [metaLogEntry setUpdateData:data];

            //
            // Increment the sequence for this record
            //
            (*sequenceNumberBlock)++;
        }
    }

    - (void) logDeleteEntry:(NSSet *)deletedRecords forTransaction:(CCTransactionID *)transactionID metadataContext:(NSManagedObjectContext *)metadataContext sequenceNumberBlock: (NSUInteger *) sequenceNumberBlock {

        for (NSManagedObject * object in deletedRecords) {

            (void) [self transactionLogEntry:CCMetaLogEntryTypeDelete object:object transaction:transactionID metadataContext:metadataContext sequenceNumber:*sequenceNumberBlock];
            //
            // Increment the sequence for this record
            //
            (*sequenceNumberBlock)++;
        }
    }

    - (CCMetaLogEntry *) transactionLogEntry:(NSString const *)logRecordType object:(NSManagedObject *)object transaction:(CCTransactionID *)transactionID metadataContext:(NSManagedObjectContext *)metadataContext sequenceNumber: (NSUInteger) sequenceNumber {

        CCMetaLogEntry * metaLogEntry = (CCMetaLogEntry *) [NSEntityDescription insertNewObjectForEntityForName: @"CCMetaLogEntry" inManagedObjectContext: metadataContext];

        [metaLogEntry setTransactionID:transactionID];
        [metaLogEntry setSequenceNumber:@(sequenceNumber)];
        [metaLogEntry setSequenceNumber:@(sequenceNumber - 1)];
        [metaLogEntry setType:logRecordType];
        [metaLogEntry setTimestamp:[NSDate date]];
        //
        // Update the object identification data
        //
#warning [transactionLogEntry setUpdateUniqueID: <Need to determine Unique ID field>]
        [metaLogEntry setUpdateObjectID:[[[object objectID] URIRepresentation] absoluteString]];
        [metaLogEntry setUpdateEntityName:[[object entity] name]];

        return metaLogEntry;
    }

@end

@implementation CCWriteAheadLog (Initialization)

    - (void) initializeSequenceNumberGenerator {
        @synchronized (self) {

#warning This should be gotten from a table stored in the DB so we have continues sequence numbering
            //
            // We need to find the last log entry and get it's
            // sequenceNumber value to calculate the next number
            // in the database.
            //
            NSManagedObjectContext * metadataContext = [self transactionLogEditContext];

            NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CCMetaLogEntry"];

            [fetchRequest setFetchLimit: 1];
            [fetchRequest  setSortDescriptors: @[[NSSortDescriptor sortDescriptorWithKey:@"sequenceNumber" ascending:NO]]];

            NSError *error = nil;

            CCMetaLogEntry * lastLogRecord = [[metadataContext executeFetchRequest:fetchRequest error: &error] lastObject];

            if (lastLogRecord) {
                nextSequenceNumber = [[lastLogRecord sequenceNumber] unsignedIntegerValue] + 1;
            } else {
                nextSequenceNumber = 1;
            }
        }
    }

@end
