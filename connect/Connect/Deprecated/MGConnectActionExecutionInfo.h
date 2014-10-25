//
//  MGConnectActionExecutionInfo.h
//  Connect
//
//  Created by Tony Stone on 5/25/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectAction.h"

/**
 Object returned in the completion block with statistics
 about the execution of the action.
 */
@interface MGConnectActionExecutionInfo : NSObject

    /**
     Time the action started execution
     */
    - (NSDate *) startTime;

    /**
     Time the action ended execution
     */
    - (NSDate *) endTime;

    /**
     Total execution time
     */
    - (NSTimeInterval) executionTime;

    /**
     Completion status as returned by your action
     */
    - (MGConnectActionCompletionStatus) completionStatus;

    /**
     If there was an execution error, you can get it here.
     */
    - (NSError *) error;

    /**
     Info returned from an implmentation of MGConnectAction
     */
    - (NSDictionary *) userInfo;

@end


/**
 CompletionBlock passed to execute methods
 
 NOTE: If you specify a completion block, it will called back on the main thread
 */
typedef void (^MGConnectActionCompletionBlock)(MGConnectActionExecutionInfo * executionInfo);

