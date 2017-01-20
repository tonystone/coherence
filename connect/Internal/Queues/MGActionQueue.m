//
//  MGActionQueue.m
//  MGConnect
//
//  Created by Tony Stone on 4/1/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGActionQueue.h"
#import "MGActionNotificationService.h"
@import TraceLog;
#import "MGConnect+EntityAction.h"


#define kQueueLabelFormat @"com.mobilegridinc.queue.%@"

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

- (void) addAction: (MGEntityAction *) anAction waitUntilDone: (BOOL) wait {
    
    //
    // Register the operation first so the users get notifications
    //
    [MGActionNotificationService registerActionForNotification: anAction];
    
    [queue addOperations: @[anAction] waitUntilFinished: wait];
}

- (NSArray *) actions {
    return [queue operations];
}

@end
