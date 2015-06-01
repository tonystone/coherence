//
// Created by Tony Stone on 5/15/15.
//

#import "CCCache.h"
#import "CCPersistentStoreCoordinator.h"
#import "CCBackingStore.h"
#import "CCSynchronizationManager.h"
#import "CCManagedObjectContext.h"
#import "CCMetaModel.h"

#import "CCAssert.h"
#import "CCWriteAheadLog.h"
#import <TraceLog/TraceLog.h>

@implementation CCCache {
        CCBackingStore *_cache;

        CCSynchronizationManager *_synchronizationManager;

        CCManagedObjectContext   *_mainThreadContext;
        CCWriteAheadLog          *_writeAheadLog;
    }

    - (instancetype) initWithManagedObjectModel:(NSManagedObjectModel *)model {

        NSParameterAssert(model != nil);

        LogInfo(@"Initializing '%@' instance...", NSStringFromClass([self class]));

        self = [super init];
        if (self) {
            _cache = [[CCBackingStore alloc] initWithManagedObjectModel:model];
            _synchronizationManager = [[CCSynchronizationManager alloc] initWithCache:_cache metaCache:nil];

            //
            // We don't know if we're going to be created
            // on a background thread or not so we're
            // protecting the creation of the _mainThreadContext
            //
            [self performSelectorOnMainThread: @selector(createMainThreadContext) withObject:nil waitUntilDone: YES];

            // Start up the system
            [self start];
        }

        return self;
    }

    - (void) createMainThreadContext {
        AssertIsMainThread();

        LogInfo(@"Creating main thread context...");

        _mainThreadContext = [[CCManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
        [_mainThreadContext setPersistentStoreCoordinator: [_cache persistentStoreCoordinator]];

        LogInfo(@"Main thread context created.");
    }

    - (void) start {
        LogInfo(@"Starting...");
        [_synchronizationManager start];
        LogInfo(@"Started.");
    }

    - (void) stop {
        LogInfo(@"Stopping...");
        [_synchronizationManager stop];
        LogInfo(@"Stopped.");
    }

    - (NSManagedObjectContext *) mainThreadContext {
        AssertIsMainThread();

        return _mainThreadContext;
    }

    - (NSManagedObjectContext *) editContext {
        LogInfo(@"Creating edit context...");
        
        NSManagedObjectContext * context = [[CCManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType parent: _mainThreadContext];
        [context setPersistentStoreCoordinator: [_cache persistentStoreCoordinator]];
        
        LogInfo(@"Edit context created.");
        
        return context;
    }


@end
