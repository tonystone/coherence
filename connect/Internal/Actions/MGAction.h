//
//  MGAction.h
//  MGConnect
//
//  Created by Tony Stone on 4/16/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGConnect+Action.h"

@interface MGAction : NSOperation <MGAction> {
@package
    NSString  * type;
}

    /**
     Main execution metho which starts this particular web service
     
     NOTE: You must override this method.  Do NOT override start from NSOperation.
     */
    - (MGActionCompletionStatus) executeInContext: (id) aContext;

@end

@interface MGAction (InternalSubclasses)

    /**
     Internal operational methods to be called by subclasses only
     */
    - (void) executionStarted;
    - (void)   executionEnded: (MGActionCompletionStatus) aCompletionStatus;

    /**
     If you get an error, set it in the action class
     */
    - (void) setError: (NSError *) error;

    /**
     Set a special completion block for this action.
     */
    - (void) setCompletionBlockWithStatus: (MGActionCompletionBlock) aCompletionBlock;

@end

@interface MGAction (Initialization)

- (id) initWithType: (NSString *) anActionType;

@end

