//
//  MGConnectActionMonitor.h
//  Connect
//
//  Created by Tony Stone on 5/9/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// Forward definitions
//
@protocol MGConnectAction;
@class MGConnectActionExecutionInfo;

/**
 This delegate protocol defines the callbacks you may receive
 for actions that execute on Entities within you model.
 
 */
@protocol MGConnectActionMonitor <NSObject>
@required
    - (void)   actionStarted: (id <MGConnectAction>) anAction;
    - (void)  actionFinished: (id <MGConnectAction>) anAction executionInfo: (MGConnectActionExecutionInfo *) executionInfo;

@end
