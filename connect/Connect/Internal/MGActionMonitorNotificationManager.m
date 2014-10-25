//
//  MGActionMonitorNotificationManager.m
//  Connect
//
//  Created by Tony Stone on 5/24/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGActionMonitorNotificationManager.h"
#import "MGConnectActionMonitor.h"
#import "MGConnectPersistentStoreCoordinator.h"
#import "MGActionQueue.h"
#import "MGActionExecutionProxy.h"

#import "MGTraceLog.h"

@implementation MGActionMonitorNotificationManager {
    NSPointerArray         * globalMonitors;
    CFMutableDictionaryRef   entityMonitors;
    NSObject               * entityMonitorsGuard;
}

static MGActionMonitorNotificationManager * sharedManager;

+ (void) initialize {
    
    if (self == [MGActionMonitorNotificationManager class]) {
        sharedManager = [[self alloc] init];
    }
}

+ (MGActionMonitorNotificationManager *) sharedManager {
    return sharedManager;
}

- (id) init{
    
    if ((self = [super init])) {
        globalMonitors      = [NSPointerArray weakObjectsPointerArray];
        entityMonitors      = CFDictionaryCreateMutable(NULL, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        entityMonitorsGuard = [[NSObject alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleActionQueuedNotification:)   name: MGConnectActionQueuedNotification   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleActionStartedNotification:)  name: MGConnectActionStartedNotification  object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleActionFinishedNotification:) name: MGConnectActionFinishedNotification object: nil];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void) registerActionMonitor: (id <MGConnectActionMonitor>) monitor {
    
    @synchronized(globalMonitors) {
        LogInfo(@"Adding action monitor %@", monitor);
        
        [globalMonitors addPointer: (__bridge void *)(monitor)];
    }
}

- (void) unregisterActionMonitor: (id <MGConnectActionMonitor>) monitor {
    @synchronized(globalMonitors) {
        for (NSUInteger i = 0;  i < [globalMonitors count]; i++) {
            if ([globalMonitors pointerAtIndex: i] == (__bridge void *)(monitor)) {
                [globalMonitors removePointerAtIndex: i];
                
                break;
            }
        }
    }
}

- (void) registerActionMonitor: (id <MGConnectActionMonitor>) monitor forEntity: (NSEntityDescription *) entity {
    
    @synchronized(entityMonitorsGuard) {
        NSPointerArray * monitors = CFDictionaryGetValue(entityMonitors, (__bridge const void *) entity);
        
        if (!monitors) {
            monitors = [NSPointerArray weakObjectsPointerArray];
            CFDictionarySetValue(entityMonitors, CFBridgingRetain(entity), CFBridgingRetain(monitors));
        }
        
        LogInfo(@"Adding action monitor %@ for entity %@<%p>", monitor, [entity name], entity);
        
        [monitors addPointer: (__bridge void *)(monitor)];
    }
}

- (void) unregisterActionMonitor: (id <MGConnectActionMonitor>) monitor forEntity: (NSEntityDescription *) entity {
    
}

- (void) handleActionQueuedNotification: (NSNotification *) notification {
    
}

- (void) handleActionStartedNotification: (NSNotification *) notification {
    id action = [[notification userInfo] objectForKey: MGConnectActionKey];
    
    NSParameterAssert(action != nil);
    NSAssert([action conformsToProtocol: @protocol(MGConnectAction)], @"Class %@ must conform to protocol %@", [action class], NSStringFromProtocol(@protocol(MGConnectAction)));

    //
    // Handle the global monitors first.
    //
    @synchronized(globalMonitors) {
        for (id monitor in globalMonitors) {
            
            LogTrace(4, @"%@", monitor != NULL ? [NSString stringWithFormat: @"Monitor %@ found and is being called for actionStarted: with \r\raction {%@}", monitor, action] : @"NULL monitor found");
            
            if (monitor != NULL && [monitor respondsToSelector: @selector(actionStarted:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    LogTrace(1, @"Calling action monitor %@ actionStarted: with action %@", monitor, action);
                    
                    [monitor actionStarted: action];
                });
            }
        }
    }
    
    //
    // Now if this is an EntityAction, we can notify
    // any entity monitors if present
    //
    if ([action respondsToSelector: @selector(entity)]) {
        NSPointerArray * monitors = CFDictionaryGetValue(entityMonitors, (__bridge const void *) [action entity]);
        
        if (monitors) {
            @synchronized(monitors) {
                for (id monitor in monitors) {
                    
                    LogTrace(4, @"%@", monitor != NULL ? [NSString stringWithFormat: @"Entity monitor %@ found and is being called for actionStarted: with \r\raction \"%@\"", monitor, action] : @"NULL entity monitor found");
                    
                    if (monitor != NULL && [monitor respondsToSelector: @selector(actionStarted:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            LogTrace(1, @"Calling action monitor %@ actionStarted: with action %@", monitor, action);
                            
                            [monitor actionStarted: action];
                        });
                    }
                }
            }
        }
    }
}

- (void) handleActionFinishedNotification: (NSNotification *) notification {
    id action                                    = [[notification userInfo] objectForKey: MGConnectActionKey];
    MGConnectActionExecutionInfo * executionInfo = [[notification userInfo] objectForKey: MGConnectActionExecutionInfoKey];
    
    NSParameterAssert(action != nil);
    NSAssert([action conformsToProtocol: @protocol(MGConnectAction)], @"Class %@ must conform to protocol %@", [action class], NSStringFromProtocol(@protocol(MGConnectAction)));
    
    //
    // Handle the global monitors first.
    //
    @synchronized(globalMonitors) {
        for (id monitor in globalMonitors) {
            
            LogTrace(4, @"%@", monitor != NULL ? [NSString stringWithFormat: @"Monitor %@ found and is being called for actionFinished:executionInfo: with \r\raction \"%@\"", monitor, action] : @"NULL monitor found");
            
            if (monitor != NULL && [monitor respondsToSelector: @selector(actionFinished:executionInfo:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    LogTrace(1, @"Calling action monitor %@ actionFinished:executionInfo: with \r\raction %@", monitor, action);
                    
                    [monitor actionFinished: action executionInfo: executionInfo];
                });
            }
        }
    }
    
    //
    // Now if this is an EntityAction, we can notify
    // any entity monitors if present
    //
    if ([action respondsToSelector: @selector(entity)]) {
        NSPointerArray * monitors = CFDictionaryGetValue(entityMonitors, (__bridge const void *) [action entity]);
        
        if (monitors) {
            @synchronized(monitors) {
                for (id monitor in monitors) {
                    
                    LogTrace(4, @"%@", monitor != NULL ? [NSString stringWithFormat: @"Entity monitor %@ found and is being called for actionFinished:executionInfo: with \r\raction \"%@\"", monitor, action] : @"NULL entity monitor found");
                    
                    if (monitor != NULL && [monitor respondsToSelector: @selector(actionFinished:executionInfo:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            LogTrace(1, @"Calling action monitor %@ actionFinished:executionInfo: with \r\raction %@", monitor, action);
                            
                            [monitor actionFinished: action executionInfo: executionInfo];
                        });
                    }
                }
            }
        }
    }
}

@end
