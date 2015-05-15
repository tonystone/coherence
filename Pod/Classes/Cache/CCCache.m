//
// Created by Tony Stone on 5/15/15.
//

#import "CCCache.h"
#import "CCBackingStore.h"
#import "CCSynchronizationManager.h"
#import "CCManagedObjectContext.h"
#import "CCMetaModel.h"

#import "CCAssert.h"
#import "CCWriteAheadLog.h"
#import <TraceLog/TraceLog.h>


@implementation CCCache {
        CCBackingStore * cache;
        CCBackingStore * metaCache;

        CCSynchronizationManager * synchronizationManager;

        CCManagedObjectContext   * mainThreadContext;
        CCWriteAheadLog          * writeAheadLog;
    }

    - (instancetype)initWithIdentifier: (NSString *) anIdentifier managedObjectModel:(NSManagedObjectModel *)model {

        NSParameterAssert(anIdentifier != nil);
        NSParameterAssert(model != nil);

        LogInfo(@"Initializing '%@' instance...", NSStringFromClass([self class]));

        self = [super init];
        if (self) {
            cache                   = [[CCBackingStore alloc] initWithIdentifier: anIdentifier managedObjectModel: model];
            metaCache               = [[CCBackingStore alloc] initWithIdentifier: [anIdentifier stringByAppendingString: @"Meta"] managedObjectModel: [CCMetaModel managedObjectModel]];

            writeAheadLog           = [[CCWriteAheadLog alloc] initWithMetadataStore: metaCache];

            synchronizationManager  = [[CCSynchronizationManager alloc] initWithCache: cache metaCache: metaCache];

            //
            // We don't know if we're going to be created
            // on a background thread or not so we're
            // protecting the creation of the mainThreadContext
            //
            [self performSelectorOnMainThread: @selector(createMainThreadContext) withObject:nil waitUntilDone: YES];

            // Start up the system
            [self start];
        }

        return self;
    }

    - (void) createMainThreadContext {
        AssertIsMainThread();

        LogTrace(1,@"Creating main thread context...");

        mainThreadContext = [[CCManagedObjectContext alloc] initWithBackingStore: cache writeAheadLog: writeAheadLog];
        [mainThreadContext setPersistentStoreCoordinator:[cache persistentStoreCoordinator]];

        LogTrace(1,@"Main thread context created.");
    }

    - (void)start {
        LogInfo(@"Starting...");
        [synchronizationManager start];
        LogInfo(@"Started.");
    }

    - (void)stop {
        LogInfo(@"Stopping...");
        [synchronizationManager stop];
        LogInfo(@"Stopped.");
    }

    - (NSManagedObjectContext *)mainThreadContext {
        AssertIsMainThread();

        return mainThreadContext;
    }

    - (NSManagedObjectContext *)editContext {
        CCManagedObjectContext * editContext = [[CCManagedObjectContext alloc] initWithBackingStore: cache writeAheadLog: writeAheadLog];

        [editContext setPersistentStoreCoordinator:[cache persistentStoreCoordinator]];

        return editContext;
    }

@end
