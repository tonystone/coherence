//
// Created by Tony Stone on 4/30/15.
//

#import "CCManagedObjectContext.h"
#import "CCWriteAheadLog.h"
#import "CCBackingStore.h"

#import <TraceLog/TraceLog.h>

@implementation CCManagedObjectContext {
        CCBackingStore         __weak * backingStore;
        CCWriteAheadLog        __weak * writeAheadLog;
        CCManagedObjectContext __weak * parent;
    }

    - (id)initWithBackingStore:(CCBackingStore *)aBackingStore writeAheadLog:(CCWriteAheadLog *)aWriteAheadLog {
        return [self initWithBackingStore: aBackingStore writeAheadLog: aWriteAheadLog parent: nil];
    }

    - (id)initWithBackingStore:(CCBackingStore *)aBackingStore writeAheadLog:(CCWriteAheadLog *) aWriteAheadLog  parent: (CCManagedObjectContext *) aParent {

        NSParameterAssert(aBackingStore != nil);

        LogInfo(@"Initializing with transaction logging %@...", aWriteAheadLog ? @"\"Enabled\"" : @"\"Disabled\"");

        if ((self = [super init])) {
            writeAheadLog = aWriteAheadLog;
            backingStore  = aBackingStore;
            parent        = aParent;

            [self setPersistentStoreCoordinator: [backingStore persistentStoreCoordinator]];

            if (parent) {
                [parent registerListener: self];
            }
        }
        LogInfo(@"Initialized");

        return self;
    }

    - (void) dealloc {
        if (parent) {
            [parent unregisterListener: self];
        }
        //
        // If we get deallocated before the children,
        // we need to make sure we unregister all the
        // children because they wont be able to call
        // back.
        //
        [[NSNotificationCenter defaultCenter] removeObserver: self];
    }

    - (BOOL) save:(NSError * *)error {
        return [self save:error logChanges: YES];
    }

    - (BOOL)save:(NSError **)error logChanges: (BOOL)logChanges {

        if (writeAheadLog && logChanges) {

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
            NSError * saveError = nil;

            BOOL success = [super save: &saveError];
            if (!success) {
                [writeAheadLog removeTransaction: transactionID];

                @throw [NSException exceptionWithName: @"Write Ahead Log Exception" reason: [NSString stringWithFormat: @"Failed to write transcation to log: %@", saveError ? [saveError localizedDescription] : @"Unknown reason"] userInfo: nil];
            }

            return success;
        }
        return [super save: error];
    }

    - (NSArray *) executeFetchRequest:(NSFetchRequest *)request error:(NSError * *)error {
        NSEntityDescription * entity = [request entity];

        if (!entity) {
            @throw [NSException exceptionWithName: @"FetchRequest Exception" reason: @"NSFetchRequest without an NSEntityDescription" userInfo: nil];
        }

        return [super executeFetchRequest: request error: error];
    }

    - (void) refreshObject:(NSManagedObject *)object mergeChanges:(BOOL)mergeChanges {
        [super refreshObject: object mergeChanges: mergeChanges];
    }

    - (void)registerListener:(CCManagedObjectContext *)listener {
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleContextDidSaveNotification:) name: NSManagedObjectContextDidSaveNotification object: listener];
    }

    - (void)unregisterListener:(CCManagedObjectContext *)listener {
        [[NSNotificationCenter defaultCenter] removeObserver: self name: NSManagedObjectContextDidSaveNotification object: listener];
    }

    - (void) handleContextDidSaveNotification:(NSNotification *) notification {

        void (^mergeChanges)(void) = ^{

            @autoreleasepool {

                [[self undoManager] disableUndoRegistration];

                // Merge the changes into our main context
                [self mergeChangesFromContextDidSaveNotification: notification];

                NSError * error = nil;

                if (![self save:&error logChanges: NO]) {
                    @throw [NSException exceptionWithName: @"Merge Exception" reason: [error localizedDescription] userInfo: @{@"error": error}];
                }

                [[self undoManager] enableUndoRegistration];
            }
        };

        if ([NSThread isMainThread]) {
            mergeChanges();
        } else {
            //
            // Dispatch the merging of changes to
            // the main thread if not on it.
            //
            dispatch_sync(dispatch_get_main_queue(), mergeChanges);
        }
    }

@end