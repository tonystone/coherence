//
//  MGActionQueue.h
//  MGConnect
//
//  Created by Tony Stone on 4/1/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

enum  {
    MGActionQueueSerial     = 1,
    MGActionQueueConcurrent = 2
};
typedef NSUInteger MGActionQueueConcurrencyMode;


@class MGEntityAction;

@interface MGActionQueue : NSObject

- (id) initWithName: (NSString *) name mode: (MGActionQueueConcurrencyMode) concurrencyMode ;

- (void) suspend;
- (void) resume;

- (void) addAction: (MGEntityAction *) anAction waitUntilDone: (BOOL) wait;

- (NSArray *) actions;

@end
