//
//  MGAction.h
//  MGConnect
//
//  Created by Tony Stone on 4/16/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGConnectAction.h"
#import "MGConnectActionController.h"

extern NSString * const MGConnectActionStartedNotification;
extern NSString * const MGConnectActionFinishedNotification;
extern NSString * const MGConnectActionKey;
extern NSString * const MGConnectActionExecutionInfoKey;

@class MGConnectPersistentStoreCoordinator;

@interface MGActionExecutionProxy : NSOperation

+ (MGActionExecutionProxy *) actionExecutionProxyForAction: (id<MGConnectAction>) action inMessage: (MGConnectActionMessage *) inMessageOrNil persistentStoreCoordinator: (MGConnectPersistentStoreCoordinator *) persistentStoreCoordinator completionBlockWithStatus: (MGConnectActionCompletionBlock) aCompletionBlock;

// Return the internal action
-  (id<MGConnectAction>) action;

// Only to be called for testing internal
- (void) executionStarted;
- (void) executionEnded: (MGConnectActionCompletionStatus) aCompletionStatus error: (NSError *) error;

@end


