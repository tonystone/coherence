//
//  MGEntityActionManager.h
//  Connect
//
//  Created by Tony Stone on 5/19/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGConnectAction.h"
#import "MGConnectActionExecutionInfo.h"
#import "MGConnectActionMessage.h"

//
// Forward Definitions
//
@class NSPersistentStoreCoordinator;
@class NSEntityDescription;
@class MGConnectEntityAction;


/**
 */
@interface MGConnectActionController : NSObject

    /**
     Designated Initializer
     */
    - (id) initWithPersistentStoreCoordinator: (NSPersistentStoreCoordinator *) aPersistentStoreCoordinator;

    /**
     Returns an instance of the action with name for the entity that was previously registered with the system
     
     NOTE: These must be pre-registered with the system by either specifying 
           a MGEntityActionDefinition class or preregistering your own
           action as the name specified.
     */
    - (MGConnectEntityAction *) registeredEntityAction: (NSString *) actionName entity: (NSEntityDescription *) entity;

    /**
     Execute an action
     
     Since the copmpletionBlock is called on the main thread, this method will throw an exception if you 
     pass YES to waitUntilDone while on the main thread and pass a completionBlock.
     */
    - (void) executeAction: (id<MGConnectAction>) action completionBlock:(MGConnectActionCompletionBlock)completionBlock waitUntilDone:(BOOL)waitUntilDone;

    /**
     Execute an action passing it the inMessage you specify. 
     
     Since the copmpletionBlock is called on the main thread, this method will throw an exception if you
     pass YES to waitUntilDone while on the main thread and pass a completionBlock.
     */
    - (void) executeAction: (id<MGConnectAction>) action inMessage: (MGConnectActionMessage *) inMessage completionBlock:(MGConnectActionCompletionBlock)completionBlock waitUntilDone:(BOOL)waitUntilDone;

@end