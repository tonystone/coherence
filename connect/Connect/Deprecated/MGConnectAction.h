//
//  MGConnect+EntityAction.h
//  MGConnect
//
//  Created by Tony Stone on 3/28/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnect.h"
#import <CoreData/CoreData.h>

//
// forward definitions
//
@class MGConnectActionMessage;

/** @enum
 CompletionStatus of the action
 */
enum {
    MGConnectActionCompletionStatusSuccessful = 0,
    MGConnectActionCompletionStatusCancelled  = 1,
    MGConnectActionCompletionStatusFailed     = 2
};
typedef NSUInteger MGConnectActionCompletionStatus;

/** @protocol

 The MGAction protocol will allow you to monitor the
 action before, during, and after execution.

 The MGEntityAction protocol includes
 a property to identify the NSEntityDescription
 that this action is for.
 */
@protocol MGConnectAction <NSObject>

@required
    @property (nonatomic, readonly) NSString  * name;

@optional
    - (MGConnectActionCompletionStatus) execute: (id) contextData inMessage: (MGConnectActionMessage *) inMessage error: (NSError * __autoreleasing *) error;

@end

/** @interface

 It is optional to subclass MGConnectAction but if you do
 you get the added benifit of having dependencies and
 priorities.
 */
@interface MGConnectAction : NSObject <MGConnectAction>

    /**
     Designated Initializer
     */
    - (id) initWithName: (NSString *) name;

    /**
     Returns the name of this MGConnectAction
     */
    - (NSString *) name;

    - (NSArray *) dependencies;

    - (void)    addDependency: (id <MGConnectAction>) action;
    - (void) removeDependency: (id <MGConnectAction>) action;

@end



