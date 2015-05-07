//
// Created by Tony Stone on 4/30/15.
//

#import "CCManagedObjectContext.h"
#import "CCWriteAheadLog.h"
#import "CCBackingStore.h"

#import <TraceLog/TraceLog.h>

@implementation CCManagedObjectContext {
        CCBackingStore __unsafe_unretained *  backingStore;
        CCWriteAheadLog                    * writeAheadLog;

        BOOL              logTransactions;
    }

    - (id)initWithBackingStore:(CCBackingStore *)aBackingStore writeAheadLog:(CCWriteAheadLog *) aWriteAheadLog  {

        LogInfo(@"Initializing with logging %@...", aWriteAheadLog ? @"\"ON\"" : @"\"OFF\"");

        if ((self = [super init])) {
            writeAheadLog     = aWriteAheadLog;
            logTransactions   = writeAheadLog != nil;

            [self setPersistentStoreCoordinator: [backingStore persistentStoreCoordinator]];
        }
        LogInfo(@"Initialized");

        return self;
    }

//
//    - (id) initWithDataStoreManager: (MGDataStoreManager *) aDataStoreManager notificationSelector: (SEL) aSelector transactionLogManager: (MGTransactionLogManager *) aTransactionLogManager {
//
//        NSParameterAssert(aDataStoreManager != nil);
//        NSParameterAssert(aSelector != nil);
//        NSParameterAssert(aTransactionLogManager != nil);
//
//
//
//        if ((self = [super init])) {
//            dataStoreManager      = aDataStoreManager;
//            transactionLogManager = aTransactionLogManager;
//
//            [[NSNotificationCenter defaultCenter] addObserver: dataStoreManager selector: aSelector name: NSManagedObjectContextDidSaveNotification object: self];
//        }
//
//        LogTrace(4, @"<%@ : %p> initialized", NSStringFromClass([self class]), self);
//
//        return  self;
//    }
//
//    - (void) dealloc {
//        if (dataStoreManager) {
//            [[NSNotificationCenter defaultCenter] removeObserver: dataStoreManager name: NSManagedObjectContextDidSaveNotification object: self];
//        }
//    }
//
//    - (MGTransactionLogManager *) transactionLogManager {
//        return transactionLogManager;
//    }
//
    - (BOOL) save:(NSError *__autoreleasing *)error {

        if (logTransactions) {
            //
            // Obtain permanent IDs for all inserted objects
            //
            if (![self obtainPermanentIDsForObjects: [[self insertedObjects] allObjects] error: error]) {
                return NO;
            }

            //
            // Log the changes from the context in a transaction
            //
            CCTransactionID * transactionID = [writeAheadLog logTransactionForContextChanges: self];

            //
            // Save the main context
            //
            BOOL success = [super save: error];
            if (!success) {
                [writeAheadLog removeTransaction: transactionID];

                // @throw
            }

            return success;
        }
        return [super save: error];
    }

    - (NSArray *) executeFetchRequest:(NSFetchRequest *)request error:(NSError *__autoreleasing *)error {
        NSEntityDescription * entity = [request entity];

        if (!entity) {
            @throw [NSException exceptionWithName: @"FetchRequest Exception" reason: @"NSFetchRequest without an NSEntityDescription" userInfo: nil];
        }
//
//        if ([entity managed]) {
//            // callback data store
//        }

        return [super executeFetchRequest: request error: error];
    }

    - (void) refreshObject:(NSManagedObject *)object mergeChanges:(BOOL)mergeChanges {

    }

@end