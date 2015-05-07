//
// Created by Tony Stone on 4/30/15.
//

#import "CCSynchronizationManager.h"
#import "CCBackingStore.h"

#import <TraceLog/TraceLog.h>

@implementation CCSynchronizationManager {

    }

    - (instancetype)initWithCache:(CCBackingStore *)aCache metaCache:(CCBackingStore *)aMetaCache {

        NSParameterAssert(aCache != nil);
        NSParameterAssert(aMetaCache != nil);
        NSParameterAssert(aCache != aMetaCache);

        LogInfo(@"Initializing new instance...");

        self = [super init];
        if (self) {

        }

        LogInfo(@"New instance initialized.");

        return self;
    }

    - (void)start {
        LogInfo(@"Starting...");

        LogInfo(@"Started.");
    }

    - (void)stop {
        LogInfo(@"Stopping...");

        LogInfo(@"Stopped.");
    }

@end