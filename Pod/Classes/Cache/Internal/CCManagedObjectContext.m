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

        LogInfo(@"Initializing with transaction logging %@...", aWriteAheadLog ? @"\"Enabled\"" : @"\"Disabled\"");

        if ((self = [super init])) {
            writeAheadLog     = aWriteAheadLog;
            logTransactions   = writeAheadLog != nil;

            [self setPersistentStoreCoordinator: [backingStore persistentStoreCoordinator]];
        }
        LogInfo(@"Initialized");

        return self;
    }

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