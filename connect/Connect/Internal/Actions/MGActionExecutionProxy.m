//
//  MGAction.m
//  MGConnect
//
//  Created by Tony Stone on 4/16/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGActionExecutionProxy.h"
#import "MGTraceLog.h"
#import "MGError.h"
#import "MGConnectPersistentStoreCoordinator.h"
#import "MGConnectManagedObjectContext+Internal.h"
#import "MGConnectActionExecutionInfo.h"
#import "MGRuntimeException.h"

NSString * const MGConnectActionStartedNotification  = @"MGConnectActionStartedNotification";
NSString * const MGConnectActionFinishedNotification = @"MGConnectActionFinishedNotification";
NSString * const MGConnectActionKey                  = @"MGConnectActionKey";
NSString * const MGConnectActionExecutionInfoKey     = @"MGConnectActionExecutionInfoKey";

@interface MGConnectConcreteActionExecutionInfo : MGConnectActionExecutionInfo {
@package
    NSDate * startTime;
    NSDate * endTime;
    
    MGConnectActionCompletionStatus completionStatus;
    NSError * error;
    
    NSDictionary * userInfo;
}
@end

@implementation MGConnectConcreteActionExecutionInfo

- (NSDate *) startTime {
    return startTime;
}

- (NSDate *) endTime {
    return endTime;
}

- (NSTimeInterval) executionTime {
    return [endTime timeIntervalSinceDate: startTime];
}

- (MGConnectActionCompletionStatus) completionStatus {
    return completionStatus;
}

- (NSError *) error {
    return error;
}

- (NSDictionary *) userInfo {
    return userInfo;
}

@end


/**
 Main Implementation
 */
@implementation MGActionExecutionProxy  {
    
    id <MGConnectAction>                   action;
    MGConnectPersistentStoreCoordinator  * persistentStoreCoordinator;
    MGConnectActionMessage               * inMessage;
    MGConnectActionCompletionBlock         completionBlock;
    
    MGConnectConcreteActionExecutionInfo * executionInfo;
    
    // NSOperation attributes
    BOOL executing;
    BOOL finished;
}

+ (MGActionExecutionProxy *) actionExecutionProxyForAction: (id<MGConnectAction>) action inMessage: (MGConnectActionMessage *) inMessageOrNil persistentStoreCoordinator: (MGConnectPersistentStoreCoordinator *) persistentStoreCoordinator completionBlockWithStatus:(MGConnectActionCompletionBlock)aCompletionBlock {
     
    MGActionExecutionProxy * actionProxy  = [[self alloc] initWithConnectAction: action inMessage: inMessageOrNil persistentStoreCoordinator: persistentStoreCoordinator completionBlockWithStatus: aCompletionBlock];
    
    if ([action isKindOfClass: [MGConnectAction class]]) {
        
        for (id <MGConnectAction> dependentAction in [(MGConnectAction *)action dependencies]) {
            [actionProxy addDependency: [self actionExecutionProxyForAction: dependentAction inMessage: [MGConnectActionMessage actionMessage] persistentStoreCoordinator: persistentStoreCoordinator completionBlockWithStatus: nil]];
        }
    }
    return actionProxy;
}

- (id) initWithConnectAction: (id<MGConnectAction>) anAction  inMessage: (MGConnectActionMessage *) anInMessage persistentStoreCoordinator:(MGConnectPersistentStoreCoordinator *)aPersistentStoreCoordinator completionBlockWithStatus:(MGConnectActionCompletionBlock)aCompletionBlock {
    
    NSParameterAssert(anAction != nil);
    NSParameterAssert(anInMessage != nil);
    NSAssert([anAction conformsToProtocol: @protocol(MGConnectAction)], @"");
    NSParameterAssert(aPersistentStoreCoordinator != nil);
    
    if ((self = [super init])) {
        action                     = anAction;
        persistentStoreCoordinator = aPersistentStoreCoordinator;
        inMessage                  = anInMessage;
        
        //
        // Must set through setter so the observation gets put in place.
        //
        [self setCompletionBlockWithStatus: aCompletionBlock];
        
        executionInfo = [[MGConnectConcreteActionExecutionInfo alloc] init];
        
        executing = NO;
        finished  = NO;
    }
    return self;
}

- (id <MGConnectAction>) action {
    return action;
}

- (BOOL) isExecuting {
    return executing;
}

- (BOOL) isFinished {
    return finished;
}

- (void) setExecuting: (BOOL) yesOrNo {
    
    if (executing != yesOrNo) {
        [self willChangeValueForKey: @"isExecuting"];
        executing = yesOrNo;
        [self didChangeValueForKey: @"isExecuting"];
    }
}

- (void) setFinished: (BOOL) yesOrNo {
  
    if (finished != yesOrNo) {
        [self willChangeValueForKey: @"isFinished"];
        finished = yesOrNo;
        [self didChangeValueForKey: @"isFinished"];
    }
}

- (void) start {
    
    @autoreleasepool {
        
        MGConnectActionCompletionStatus completionStatus = MGConnectActionCompletionStatusCancelled;
        NSError * error = nil;
        
        [self executionStarted];
        
        if (![self isCancelled]) {
            @try {

                completionStatus = [action execute: persistentStoreCoordinator inMessage: inMessage error: &error];
            }
            @catch (NSException *exception) {
                error = [NSError errorWithDomain: MGErrorDomain code: -1200 userInfo: @{NSLocalizedDescriptionKey: [NSString stringWithFormat: @"Action threw an unexpected exception: %@", [exception description]]}];
            }
        }
        [self executionEnded: completionStatus error: error];
    }
}

- (MGConnectPersistentStoreCoordinator *) persistentStoreCoordinator {
    return persistentStoreCoordinator;
}

- (void) setPersistentStoreCoordinator: (MGConnectPersistentStoreCoordinator *) aPersistentStoreCoordinator {
    
    if (persistentStoreCoordinator != aPersistentStoreCoordinator) {
        persistentStoreCoordinator = aPersistentStoreCoordinator;
    }
}
- (void) executionStarted {
    
    // Capture the time first thing to get the most accurate start time
    executionInfo->startTime = [NSDate date];
    
    // Mark the operation started
    [self setExecuting: YES];
    
    LogInfo(@"Started executing on thread %@\r\raction: %@\r", [NSThread currentThread], action);
    
    //
    // Internal notification which is not meant for the public
    // This means we send it on the thread we're on.
    //
    [[NSNotificationCenter defaultCenter] postNotificationName: MGConnectActionStartedNotification object: persistentStoreCoordinator userInfo: @{MGConnectActionKey: action}];
}

- (void) executionEnded: (MGConnectActionCompletionStatus) aCompletionStatus error: (NSError *) error {
    //
    // EndTime is needed for statics so capture now.
    executionInfo->endTime          = [NSDate date];
    executionInfo->completionStatus = aCompletionStatus;
    executionInfo->error            = error;

    [self setExecuting: NO];
    [self setFinished: YES];
    
    LogInfo(@"Finished executing on thread %@\r\raction: %@\r%@\r", [NSThread currentThread], action, executionInfo);
    
    //
    // Internal notification which is not meant for the public
    // This means we send it on the thread we're on.
    //
    [[NSNotificationCenter defaultCenter] postNotificationName: MGConnectActionFinishedNotification object: persistentStoreCoordinator userInfo: @{MGConnectActionKey: action, MGConnectActionExecutionInfoKey: executionInfo}];

    if (completionBlock) {
        //
        // Execute the users completeion block
        //
        // Note that this is done through a perform method so that the users completion block
        // will have the default exeception handler to catch any exceptions.
        //
        // If we used GCD, exception in the user blocks could go unnoticed.
        //
        [self performSelectorOnMainThread: @selector(executeUserCompletionBlock) withObject: nil waitUntilDone: YES];
    }
}

- (void) setCompletionBlockWithStatus: (MGConnectActionCompletionBlock) aCompletionBlock {
    
    if (aCompletionBlock != completionBlock) {
        completionBlock = aCompletionBlock;
    }
}

- (void) executeUserCompletionBlock {
    completionBlock(executionInfo);
}

@end
