//
// Created by Tony Stone on 4/30/15.
//

#import "CCWriteAheadLog.h"
#import "CCBackingStore.h"
#import "CCMetaModel.h"
#import "CCMetaLogEntry.h"

#import <TraceLog/TraceLog.h>

@interface CCWriteAheadLog (Initialization)
    - (void) initializeSequenceNumberGenerator;
@end

@implementation CCWriteAheadLog {
        NSManagedObjectContext * _metadataContext;

        NSUInteger nextSequenceNumber;
    }

    - (id) initWithURL: (NSURL *) url {

        NSParameterAssert(url != nil);

        LogInfo(@"Initializing '%@' instance...", NSStringFromClass([self class]));

        if ((self = [super init])) {
            NSManagedObjectModel         * managedObjectModel         = [CCMetaModel managedObjectModel];
            NSPersistentStoreCoordinator * persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel];

            NSError       * error       = nil;
            NSFileManager * fileManager = [NSFileManager defaultManager];

            if ([fileManager fileExistsAtPath: [url path]]) {

                NSDictionary * metadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType: NSSQLiteStoreType URL: url error: &error];

                if (![managedObjectModel isConfiguration: nil compatibleWithStoreMetadata:metadata]) {

                    LogWarning(@"Removing incompatible metadata persistent store at path %@", url);

                    //
                    // If the existing persistentStore is not compatible with the structure
                    // provided, we need to delete it and recreate it.
                    //
                    if (![fileManager removeItemAtPath: [url path] error: &error]) {
                        @throw [NSException exceptionWithName: @"PersistentStore Creation Exception" reason: [NSString stringWithFormat: @"%@: Could not remove incompatible persistent store", [error localizedDescription]] userInfo: nil];
                    }

                    LogWarning(@"Persistent store removed");
                }
            }
            
            LogInfo(@"Attaching persistent store for type: %@ at path: %@...", NSSQLiteStoreType, url);
            
            NSPersistentStore * persistentStore = [persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType configuration:nil URL: url options:nil error:&error];

            if (!persistentStore) {
                @throw [NSException exceptionWithName: @"Failed to add PersistentStore." reason: [error localizedDescription] userInfo: nil];
            }

#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
            //
            // Check to make sure the protection key is NSFileProtectionComplete
            //
            NSDictionary * currentAttributes = [fileManager attributesOfItemAtPath: [url path] error: nil];

            if (currentAttributes[NSFileProtectionKey] != NSFileProtectionComplete) {
                [fileManager setAttributes: @{NSFileProtectionKey: NSFileProtectionComplete} ofItemAtPath: [url path] error: nil];
            };
#endif
            _metadataContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
            [_metadataContext setPersistentStoreCoordinator: persistentStoreCoordinator];
            [_metadataContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];

            [self initializeSequenceNumberGenerator];
            
            LogInfo(@"'%@' instance initialized.", NSStringFromClass([self class]));
        }
        
        return self;
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
        NSUInteger         sequenceNumberBlockSize = 2 + [inserted count] + [updated count] + [deleted count];
        NSUInteger __block sequenceNumberBlock     = [self nextSequenceNumberBlock: sequenceNumberBlockSize];

        NSError         __block * error         = nil;
        CCTransactionID __block * transactionID = nil;

        [_metadataContext performBlockAndWait:^{

            @try {
                transactionID = [self logBeginTransactionEntry:_metadataContext sequenceNumberBlock:&sequenceNumberBlock];

                [self logInsertEntry:[transactionContext insertedObjects] forTransaction:transactionID metadataContext:_metadataContext sequenceNumberBlock:&sequenceNumberBlock];
                [self logUpdateEntry:[transactionContext updatedObjects] forTransaction:transactionID metadataContext:_metadataContext sequenceNumberBlock:&sequenceNumberBlock];
                [self logDeleteEntry:[transactionContext deletedObjects] forTransaction:transactionID metadataContext:_metadataContext sequenceNumberBlock:&sequenceNumberBlock];

                [self logEndTransactionEntry:transactionID metadataContext:_metadataContext sequenceNumberBlock:&sequenceNumberBlock];

            } @catch (NSException *exception) {
                error = [NSError errorWithDomain:@"WriteAheadLogErrorDomain" code:100 userInfo:@{NSLocalizedDescriptionKey : [exception reason]}];
            }

            if (!error && [_metadataContext hasChanges]) {
                [_metadataContext save:&error];
            }
        }];

        if (error) {
            @throw [NSException exceptionWithName: @"Runtime Exception" reason: [error localizedDescription] userInfo: @{@"error": error}];
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
            @throw [NSException exceptionWithName: @"Runtime Exception" reason: [error localizedDescription] userInfo: @{@"error": error}];
        }

        return fetchResults;
    }

#pragma mark - Internal Private methods

    - (CCTransactionID *) logBeginTransactionEntry:(NSManagedObjectContext *)metadataContext sequenceNumberBlock: (NSUInteger *) sequenceNumberBlock {
        CCTransactionID * transactionID  = nil;

        CCMetaLogEntry * metaLogEntry = (CCMetaLogEntry *) [NSEntityDescription insertNewObjectForEntityForName: @"CCMetaLogEntry" inManagedObjectContext: metadataContext];

        NSError * error = nil;

        if (![metadataContext obtainPermanentIDsForObjects: @[metaLogEntry] error: &error]) {
            @throw [NSException exceptionWithName: @"Runtime Exception" reason: [NSString stringWithFormat: @"Failed to obtain perminent id for transaction log record: %@", [error localizedDescription]] userInfo: @{@"error": error}];
        }

        //
        // We use the URI representation of the object id as the transactionID
        //
        transactionID = [[[metaLogEntry objectID] URIRepresentation] absoluteString];

        [metaLogEntry setTransactionID:transactionID];
        [metaLogEntry setSequenceNumber:@(*sequenceNumberBlock)];
        [metaLogEntry setPreviousSequenceNumber:@(*sequenceNumberBlock - 1)];
        [metaLogEntry setType: CCMetaLogEntryTypeBeginMarker];
        [metaLogEntry setTimestamp:[NSDate date]];

        //
        // Increment the sequence for this record
        //
        (*sequenceNumberBlock)++;
        
        LogTrace(4,@"Log entry created: %@", metaLogEntry);
        
        return transactionID;
    }

    - (void) logEndTransactionEntry:(CCTransactionID *)transactionID metadataContext:(NSManagedObjectContext *)metadataContext sequenceNumberBlock: (NSUInteger *) sequenceNumberBlock {

        CCMetaLogEntry * metaLogEntry = (CCMetaLogEntry *) [NSEntityDescription insertNewObjectForEntityForName: @"CCMetaLogEntry" inManagedObjectContext: metadataContext];

        [metaLogEntry setTransactionID:transactionID];
        [metaLogEntry setSequenceNumber:@(*sequenceNumberBlock)];
        [metaLogEntry setPreviousSequenceNumber:@(*sequenceNumberBlock - 1)];
        [metaLogEntry setType:CCMetaLogEntryTypeEndMarker];
        [metaLogEntry setTimestamp:[NSDate date]];
        
        //
        // Increment the sequence for this record
        //
        (*sequenceNumberBlock)++;
        
        LogTrace(4,@"Log entry created: %@", metaLogEntry);
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
            
            LogTrace(4,@"Log entry created: %@", metaLogEntry);
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
            
            LogTrace(4,@"Log entry created: %@", metaLogEntry);
        }
    }

    - (void) logDeleteEntry:(NSSet *)deletedRecords forTransaction:(CCTransactionID *)transactionID metadataContext:(NSManagedObjectContext *)metadataContext sequenceNumberBlock: (NSUInteger *) sequenceNumberBlock {

        for (NSManagedObject * object in deletedRecords) {

            CCMetaLogEntry * metaLogEntry = [self transactionLogEntry:CCMetaLogEntryTypeDelete object:object transaction:transactionID metadataContext:metadataContext sequenceNumber:*sequenceNumberBlock];
            //
            // Increment the sequence for this record
            //
            (*sequenceNumberBlock)++;
            
            LogTrace(4,@"Log entry created: %@", metaLogEntry);
        }
    }

    - (CCMetaLogEntry *) transactionLogEntry:(NSString const *)logRecordType object:(NSManagedObject *)object transaction:(CCTransactionID *)transactionID metadataContext:(NSManagedObjectContext *)metadataContext sequenceNumber: (NSUInteger) sequenceNumber {

        CCMetaLogEntry * metaLogEntry = (CCMetaLogEntry *) [NSEntityDescription insertNewObjectForEntityForName: @"CCMetaLogEntry" inManagedObjectContext: metadataContext];

        [metaLogEntry setTransactionID:transactionID];
        [metaLogEntry setSequenceNumber:@(sequenceNumber)];
        [metaLogEntry setPreviousSequenceNumber:@(sequenceNumber - 1)];
        [metaLogEntry setType:logRecordType];
        [metaLogEntry setTimestamp:[NSDate date]];
        //
        // Update the object identification data
        //
        [metaLogEntry setUpdateObjectID:[[[object objectID] URIRepresentation] absoluteString]];
        [metaLogEntry setUpdateEntityName:[[object entity] name]];

        return metaLogEntry;
    }

@end

@implementation CCWriteAheadLog (Initialization)

    - (void) initializeSequenceNumberGenerator {
        @synchronized (self) {
            //
            // We need to find the last log entry and get it's
            // sequenceNumber value to calculate the next number
            // in the database.
            //
            NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CCMetaLogEntry"];

            [fetchRequest setFetchLimit: 1];
            [fetchRequest  setSortDescriptors: @[[NSSortDescriptor sortDescriptorWithKey:@"sequenceNumber" ascending:NO]]];

            NSError *error = nil;

            CCMetaLogEntry * lastLogRecord = [[_metadataContext executeFetchRequest:fetchRequest error:&error] lastObject];

            if (lastLogRecord) {
                nextSequenceNumber = [[lastLogRecord sequenceNumber] unsignedIntegerValue] + 1;
            } else {
                nextSequenceNumber = 1;
            }
        }
    }

@end
