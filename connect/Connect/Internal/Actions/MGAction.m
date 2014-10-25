//
//  MGAction.m
//  MGConnect
//
//  Created by Tony Stone on 4/16/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGAction.h"
#import "MGConnect+Action.h"
#import "MGTraceLog.h"

//
// Internal static data
//
static NSArray * actionCompletionStatusStrings;
static NSArray * actionStateStrings;

//
// Initialize internal static structures
//
__attribute__((constructor)) static void initialize_internal_statics() {
    
    actionStateStrings            = @[@"Pending",    @"Excuting", @"Finished"];
    actionCompletionStatusStrings = @[@"Successful", @"Cancelled",@"Failed"];
}

/**
 Main Implementation
 */
@implementation MGAction  {
    MGActionState            state;
    MGActionCompletionStatus completionStatus;
    NSDictionary           * statistics;
    NSError                * error;
    MGActionCompletionBlock  completionBlock;
    
    NSDate  * actionStartTime;
    NSDate  * actionEndTime;
    
    // NSOperation attributes
    BOOL executing;
    BOOL finished;
    BOOL failed;
}

- (NSString *) type {
    return type;
}

- (BOOL) isExecuting {
    return executing;
}

- (BOOL) isFinished {
    return finished;
}

- (void) setExecuting: (BOOL) yesOrNo {
    
    if (executing != yesOrNo) {
        [self willChangeValueForKey: @"executing"];
        executing = yesOrNo;
        [self didChangeValueForKey: @"executing"];
        
        if (executing) {
            [self setState: MGActionStateExecuting];
        }
    }
}

- (void) setFinished: (BOOL) yesOrNo {
  
    if (finished != yesOrNo) {
        [self willChangeValueForKey: @"finished"];
        finished = yesOrNo;
        [self didChangeValueForKey: @"finished"];
        
        if (finished) {
            [self setState: MGActionStateFinished];
        }
    }
}

- (MGActionState) state {
    return state;
}

- (MGActionCompletionStatus) completionStatus {
    return completionStatus;
}

- (void) setState: (MGActionState) newState {
    
    if (state != newState) {
        [self willChangeValueForKey: @"state"];
        state = newState;
        [self didChangeValueForKey: @"state"];
    }
}

- (void) setCompletionStatus: (MGActionCompletionStatus) newStatus {
    
    if (completionStatus != newStatus) {
        [self willChangeValueForKey: @"completionStatus"];
        completionStatus = newStatus;
        [self didChangeValueForKey: @"completionStatus"];
    }
}

- (NSDictionary *) statistics {
    return statistics;
}

- (MGActionCompletionStatus) executeInContext: (id) aContext {
    [self doesNotRecognizeSelector: _cmd];
    return MGActionCompletionStatusFailed;
}

- (void) start {
    [self executionStarted];
    
    if (![self isCancelled]) {
        [self executionEnded: [self executeInContext: nil]];
    } else {
        [self executionEnded: MGActionCompletionStatusCancelled];
    }
}

- (void) addDependency:(NSOperation *)op {
    NSAssert([op isKindOfClass: [self class]], @"%@ class only allows dependents of type %@", [self class], [self class]);
    
    [super addDependency: op];
}

- (NSError *) error {
    NSMutableArray * dependencyErrors = [[NSMutableArray alloc] init];
    NSError        * returnError      = nil;
    
    for (id operation in [self dependencies]) {
        
        //
        // Currently, we don't allow classes of other types
        // to have depenencies but just in case we lift that
        // restriction, we check the type here.
        //
        if ([operation isKindOfClass: [MGAction class]]) {
            NSError * dependentError = [(MGAction *) operation error];
            
            if (dependentError) {
                [dependencyErrors addObject: dependentError];
            }
        }
    }
    
    if ([dependencyErrors count] > 0) {
        
        NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys: dependencyErrors, MGUnderlyingErrorsKey, nil];
        
        // If we have a local error copy the info
        if (error) {
            if ([error userInfo]) {
                [userInfo addEntriesFromDictionary: [error userInfo]];
            }
            returnError = [NSError errorWithDomain: [error domain] code: [error code] userInfo: userInfo];
        } else {
            returnError = [NSError errorWithDomain: MGErrorDomain code: MGErrorCodeActionExecutionError userInfo: userInfo];
        }
    }
    
    return returnError;
}

- (NSString *) stringFromActionCompletionStatus: (MGActionCompletionStatus) aStatus {
    
    if (aStatus < [actionCompletionStatusStrings count]) {
        return [actionCompletionStatusStrings objectAtIndex: aStatus];
    }
    return @"Unknown";
}

@end

@implementation MGAction (InternalSubclasses)

- (void) executionStarted {
    
    // Capture the time first thing to get the most accurate start time
    actionStartTime = [NSDate date];
    
    // Mark the operation started
    [self setExecuting: YES];
    
    LogInfo(@"%@ started execution on thread %@...", [self class], [NSThread currentThread]);
}

- (void) executionEnded: (MGActionCompletionStatus) aCompletionStatus {
    
    //
    // EndTime is needed for statics so capture now.
    actionEndTime = [NSDate date];
    
    NSError * executionError = [self error];
    
    statistics = [[NSMutableDictionary alloc] initWithDictionary:  @{@"start time": actionStartTime,
                  @"end time": actionEndTime,
                  @"execution time": [NSNumber numberWithDouble: [actionEndTime timeIntervalSinceDate: actionStartTime]]}];
    
    LogInfo(@"%@ finished execution:\r{\r\tcompletion status: %@\r\tstart time: %@\r\tend time: %@\r\texecution time: %@\r%@}",
            [self class],
            [self stringFromActionCompletionStatus:[self completionStatus]],
            actionStartTime,
            actionEndTime,
            [NSNumber numberWithDouble: [actionEndTime timeIntervalSinceDate: actionStartTime]],
            executionError ? [NSString stringWithFormat: @"error: %@\r", executionError] : @"");
    
    //
    // Finally set the operating state
    //
    [self setExecuting: NO];
    [self setCompletionStatus: aCompletionStatus];
    [self setFinished: YES];
}

- (void) setError:(NSError *) newValue {
    if (error != newValue) {
        error = newValue;
    }
}

- (void) setCompletionBlockWithStatus: (MGActionCompletionBlock) aCompletionBlock {
    
    if (aCompletionBlock != completionBlock) {
        completionBlock = aCompletionBlock;
        
        if (completionBlock != nil) {
            [self addObserver: self forKeyPath: @"finished" options: NSKeyValueObservingOptionNew context: nil];
        }
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    //
    // Execute the users completeion block
    //
    // Note that this is done through a perform method so that the users completion block
    // will have the default exeception handler to catch any exceptions.
    //
    // If we used GCD, exception in the user blocks could go unnoticed.
    //
    [self performSelectorOnMainThread: @selector(executeUserCompletionBlock) withObject: nil waitUntilDone: YES];
    
    [self removeObserver: self forKeyPath: @"finished"];
}

- (void) executeUserCompletionBlock {
    completionBlock(completionStatus, error);
}

@end

@implementation MGAction (Initialization)

- (id) initWithType: (NSString *) anActionType {
    
    NSParameterAssert(anActionType != nil);
    
    if ((self = [super init])) {
        type             = anActionType;
        statistics       = [NSDictionary dictionary];
        
        state     = MGActionStatePending;
        executing = NO;
        finished  = NO;
    }
    return self;
}

@end

