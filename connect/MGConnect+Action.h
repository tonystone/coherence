//
//  MGConnect+Action.h
//  MGConnect
//
//  Created by Tony Stone on 4/16/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnect.h"

/**
 Current state of the action
 */
enum {
    MGActionStatePending   = 0,
    MGActionStateExecuting = 1,
    MGActionStateFinished  = 2,
};
typedef NSUInteger MGActionState;

/**
 CompletionStatus of the action
 */
enum {
    MGActionCompletionStatusSuccessful = 0,
    MGActionCompletionStatusCancelled  = 1,
    MGActionCompletionStatusFailed     = 2
};
typedef NSUInteger MGActionCompletionStatus;

/**
 CompletionBlock passed to execute methods
 
 NOTE: These, it present, will be called back on the main thread
 */
typedef void (^MGActionCompletionBlock)(MGActionCompletionStatus status, NSError * error);

/**
 The action protocol will allow you to monitor the
 action before, during, and after execution.
 */
@protocol MGAction <NSObject>
@required
    @property (nonatomic, readonly) NSString               * type;
    @property (nonatomic, readonly) MGActionState            state;
    @property (nonatomic, readonly) MGActionCompletionStatus completionStatus;
    @property (nonatomic, readonly) NSDictionary           * statistics;
    @property (nonatomic, readonly) NSError                * error;
@end

@interface MGConnect (Action)

@end
