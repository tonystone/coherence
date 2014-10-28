//
//  MGManagedObjectContext.m
//  Connect
//
//  Created by Tony Stone on 5/8/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGManagedObjectContext.h"
#import <MGConnectCommon/MGTraceLog.h>
#import "MGRuntimeException.h"

NSString * const MGConnectManagedObjectContextDidSaveNotification = @"MGConnectManagedObjectContextDidSaveNotification";

//
// Reference count the main thread context that are synchronized.
//
// We need to limit them to ensure performance.
//
static int mainThreadSynchronizedContextLimit = 0;

static NSMutableDictionary * mainThreadSynchronizedContextCounts;

@implementation MGManagedObjectContext {
    
    struct _mgManagedObjectContextFlags {
        unsigned int logged:1;
        unsigned int synchronized:1;
        unsigned int connectManaged:1;
        unsigned int reserved:29;
    } flags;
    
    NSThread * initThread;
}

    + (void) initialize {

        if (self == [MGManagedObjectContext class]) {

            mainThreadSynchronizedContextCounts = [[NSMutableDictionary alloc] init];

//            NSDictionary * initializationOptions = [MGInitializationOptions initializationOptions:@{MGConnectMainThreadManagedObjectContextLimitOption : [NSNumber class]}];
//
//            NSNumber * limit = [initializationOptions objectForKey: MGConnectMainThreadManagedObjectContextLimitOption];
//
//            if (limit) {
//                NSAssert([limit isKindOfClass: [NSNumber class]], @"");
//
//                mainThreadSynchronizedContextLimit = [limit intValue];
//            }
        }
    }

    - (id) init {

        if ((self = [super init])) {
            self = [self commonInitSynchronizableManagedObjectContext: NO logged: YES connectManaged: YES];
        }
        return self;
    }

    - (id) initWithConcurrencyType: (NSManagedObjectContextConcurrencyType) ct {

        if ((self = [super initWithConcurrencyType: ct])) {
            self = [self commonInitSynchronizableManagedObjectContext: NO logged: YES connectManaged: YES];
        }
        return self;
    }

    - (id) initSynchronized: (BOOL) isSynchronized {

        if ((self = [super init])) {
            self = [self commonInitSynchronizableManagedObjectContext: isSynchronized logged: YES connectManaged: YES];
        }
        return self;
    }

    - (id) initWithConcurrencyType: (NSManagedObjectContextConcurrencyType) ct synchronized: (BOOL) synchronized {

        if ((self = [super initWithConcurrencyType: ct])) {
            self = [self commonInitSynchronizableManagedObjectContext: synchronized logged: NO connectManaged: YES];
        }
        return self;
    }


    - (id) initSynchronized: (BOOL) synchronized logged: (BOOL) logged connectManaged: (BOOL) connectManaged {

        if ((self = [super init])) {
            self = [self commonInitSynchronizableManagedObjectContext: synchronized logged: logged connectManaged: connectManaged];
        }
        return self;
    }

    - (id) commonInitSynchronizableManagedObjectContext: (BOOL) synchronized logged: (BOOL) logged connectManaged: (BOOL) connectManaged {

        flags.logged         = logged;
        flags.synchronized   = synchronized;
        flags.connectManaged = connectManaged;

        if (flags.synchronized) {
            initThread = [NSThread currentThread];
        }
        return self;
    }

    - (void) dealloc {

        [self removeObserverIfPresent];
        initThread = nil;
    }

    - (BOOL) logged {
        return flags.logged;
    }

    - (BOOL) synchronized {
        return flags.synchronized;
    }

    - (BOOL) connectManaged {
        return flags.connectManaged;
    }

    - (void) addObserverIfNeeded: (NSPersistentStoreCoordinator *) coordinator {
        if (flags.synchronized) {

            if (initThread == [NSThread mainThread]) {

                NSAssert([NSThread isMainThread], @"You must be on the main thread to remove observers that where set on the main thread");

                //
                // NOTE: Since this is on the main thread,
                //       we leverage it as the synchronized
                //       access to the variable below.
                //
                id coordinatorKey = [NSNumber numberWithUnsignedInteger: [coordinator hash]];

                //
                // NOTE: If objectForKey returns nil because the value is not
                //       there, the call to unsignedIntegerValue will return 0
                //       which is what we want
                //
                NSUInteger count = [[mainThreadSynchronizedContextCounts objectForKey: coordinatorKey] unsignedIntegerValue];

                if (count+1 > mainThreadSynchronizedContextLimit) {
                    @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [NSString stringWithFormat: @"You have exceded the mainThredSynchronizedContextLimit of %u, you must remove another synchronized context for this persistentStoreCoordinator before adding this one", mainThreadSynchronizedContextLimit]userInfo: nil];
                }

                count++;

                [mainThreadSynchronizedContextCounts setObject: [NSNumber numberWithUnsignedInteger: count] forKey: coordinatorKey];
            }

            //
            // Do this after everything else so if we throw an exception the notification does not get set
            //
            [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handlePersistentStoreDidSaveNotification:) name: MGConnectManagedObjectContextDidSaveNotification object: coordinator];
        }
    }

    - (void) removeObserverIfPresent {

        NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinator];

        if (coordinator && flags.synchronized) {

            [[NSNotificationCenter defaultCenter] removeObserver: self];

            if (initThread == [NSThread mainThread]) {

                NSAssert([NSThread isMainThread], @"You must be on the main thread to add observers");
                //
                // NOTE: Since this is on the main thread,
                //       we leverage it as the synchronized
                //       access to the variable below.
                //
                id coordinatorKey = [NSNumber numberWithUnsignedInteger: [coordinator hash]];

                NSUInteger count = [[mainThreadSynchronizedContextCounts objectForKey: coordinatorKey] unsignedIntegerValue];

                count--;

                [mainThreadSynchronizedContextCounts setObject: [NSNumber numberWithUnsignedInteger: count] forKey: coordinatorKey];
            }
        }
    }

    - (void) setPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator {

        if (coordinator != [self persistentStoreCoordinator]) {

            [self removeObserverIfPresent];

            if (coordinator) {
                [self addObserverIfNeeded: coordinator];
            }

            [super setPersistentStoreCoordinator: coordinator];
        }
    }

    - (BOOL) save:(NSError *__autoreleasing *)error {
        //
        // Here we create the equivalent of a notification from the NSManagedObjectContextDidSaveNotification notification.
        //
        NSNotification * contextDidSaveNotification = [NSNotification notificationWithName: NSManagedObjectContextDidSaveNotification object: self userInfo:
                @{NSInsertedObjectsKey: [self insertedObjects],
                        NSUpdatedObjectsKey:  [self updatedObjects],
                        NSDeletedObjectsKey:  [self deletedObjects]}];
        BOOL save = [super save: error];
        if (save) {
            //
            // We then post that as the persistent store.
            //
            [[NSNotificationCenter defaultCenter] postNotificationName: MGConnectManagedObjectContextDidSaveNotification object: [self persistentStoreCoordinator] userInfo: @{NSManagedObjectContextDidSaveNotification: contextDidSaveNotification}];
        }
        return save;
    }

#pragma mark - Context Management

// NOTE: From the documentation "In a multithreaded application, notifications
//       are always delivered in the thread in which the notification was posted,
//       which may not be the same thread in which an observer registered itself."
//
//      This means that care must be taken in this method to ensure we respect
//      thread and context rules.
//
    - (void) handlePersistentStoreDidSaveNotification:(NSNotification *) notification {

        //
        // Ensure this method is performed on the initThread
        //
        if ([NSThread currentThread] != initThread) {

            if (!([initThread isFinished] || [initThread isCancelled])) {
                [self performSelector: _cmd onThread: initThread withObject: notification waitUntilDone: NO];
            }
        } else {

            @try {

                //
                // Note: MGPersistentStoreCoordinator sends it's own notification that contains a self
                //       generated NSManagedObjectContextDidSaveNotification.  This notification is stored
                //       in the userInfo dictionary under the same key.  Use that as you would as if
                //       it were coming from the NSManagedObjectContext.
                //
                NSNotification * managedObjectContextDidSaveNotification = [[notification userInfo] objectForKey: NSManagedObjectContextDidSaveNotification];

                if (![[managedObjectContextDidSaveNotification object] isEqual: self]) {

                    [[self undoManager] disableUndoRegistration];

                    // Merge the changes into our main context
                    [self mergeChangesFromContextDidSaveNotification: managedObjectContextDidSaveNotification];

                    NSError * error = nil;

                    if (![self save: &error]) {
                        @throw [MGRuntimeException exceptionWithName: @"Merge Exception" reason: [error localizedDescription] userInfo: @{@"error": error}];
                    }

                    [[self undoManager] enableUndoRegistration];
                }
            }
            @catch (NSException *exception) {
                LogError(@"%@ : %@", [exception name], [exception reason]);

                // Report this error through the error system
            }
        }
    }

@end
