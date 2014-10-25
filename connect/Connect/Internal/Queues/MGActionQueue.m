//
//  MGActionQueue.m
//  MGConnect
//
//  Created by Tony Stone on 4/1/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGActionQueue.h"
#import "MGTraceLog.h"
#import "MGActionExecutionProxy.h"


//
// Notifications
//
NSString * const MGConnectActionQueuedNotification   = @"MGConnectActionQueuedNotification";

//
// Define the queue name template
//
#define kQueueLabelFormat @"com.mobilegridinc.queue.%@"

//
// Main implementation
//
@implementation MGActionQueue {
    NSOperationQueue * queue;
}

- (id) initWithName:(NSString *)name mode: (MGActionQueueConcurrencyMode) concurrencyMode {
    
    if ((self = [super init])) {

        queue = [[NSOperationQueue alloc] init];
        [queue setName: [NSString stringWithFormat: kQueueLabelFormat, name]];
        
        switch (concurrencyMode) {
            case MGActionQueueSerial:     [queue setMaxConcurrentOperationCount: 1];
            case MGActionQueueConcurrent: [queue setMaxConcurrentOperationCount: 5];
        }
        
        LogTrace(1, @"Created queue %@", [queue name]);
    }
    return self;
}

- (void) suspend {
    [queue setSuspended: YES];
}

- (void) resume {
    [queue setSuspended: NO];
}

- (void) executeActionProxy: (MGActionExecutionProxy *) actionProxy waitUntilDone: (BOOL) waitUntilDone {
    
    NSParameterAssert(actionProxy != nil);
    
    //
    // Let the rest of the system know that we queued
    //
    // We post first as if waitUntilDone is set, we'd end up
    // posting after this method is complete before anyone
    // would get notified.
    //
    [[NSNotificationCenter defaultCenter] postNotificationName: MGConnectActionQueuedNotification object: self userInfo: @{MGConnectActionKey: [actionProxy action]}];
    
    //
    // Execute the action proxy
    //
    [queue addOperations: @[actionProxy] waitUntilFinished: waitUntilDone];
    
    //
    // Now the dependencies
    //
    for (MGActionExecutionProxy * dependentActionProxy in [actionProxy dependencies]) {
        
        //
        // We don't wait here because these are children of
        // the parent, no need to wait.
        //
        [self executeActionProxy: dependentActionProxy waitUntilDone: NO];
    }
}
- (NSArray *) actions {
    return [queue operations];
}

@end
