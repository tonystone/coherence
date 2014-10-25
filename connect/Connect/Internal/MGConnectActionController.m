//
//  MGEntityActionManager.m
//  Connect
//
//  Created by Tony Stone on 5/19/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectActionController.h"
#import "MGConnectPersistentStoreCoordinator+Internal.h"
#import "MGConnectEntityActionDefinition.h"

#import "MGAssert.h"
#import "MGTraceLog.h"

#import "MGReadEntityAction.h"
#import "MGCreateEntityAction.h"
#import "MGUpdateEntityAction.h"
#import "MGDeleteEntityAction.h"


#import <CoreData/CoreData.h>

@implementation MGConnectActionController {
    MGConnectPersistentStoreCoordinator * persistentStoreCoordinator;
}

- (id) initWithPersistentStoreCoordinator: (NSPersistentStoreCoordinator *) aPersistentStoreCoordinator {
    
    NSParameterAssert(aPersistentStoreCoordinator != nil);
    NSParameterAssert([aPersistentStoreCoordinator isKindOfClass: [MGConnectPersistentStoreCoordinator class]]);
    
    if ((self = [super init])) {
        LogInfo(@"Initializing...");

        persistentStoreCoordinator = (MGConnectPersistentStoreCoordinator *) aPersistentStoreCoordinator;

        LogInfo(@"Initialized");
    }
    return self;
}

- (MGConnectEntityAction *) registeredEntityAction: (NSString *) actionName entity: (NSEntityDescription *) entity {
    
    NSParameterAssert(entity != nil);
    NSParameterAssert(actionName != nil);
    
    return [persistentStoreCoordinator registeredEntityAction: actionName entity: entity];
}

- (void) executeAction: (id<MGConnectAction>) action completionBlock:(MGConnectActionCompletionBlock)completionBlock waitUntilDone:(BOOL)waitUntilDone {
    [self executeAction: action inMessage: [MGConnectActionMessage actionMessage] completionBlock: completionBlock waitUntilDone: waitUntilDone];
}

- (void) executeAction:(id<MGConnectAction>)action inMessage: (MGConnectActionMessage *) inMessage completionBlock:(MGConnectActionCompletionBlock)completionBlock waitUntilDone:(BOOL)waitUntilDone {
  
    NSParameterAssert(action != nil);
    NSParameterAssert(inMessage != nil);
    // MGAssertIsNotMainThreadIfCondition(waitUntilDone && completionBlock);  // Note: there are reasons to execute and wait on the main thread so we're allowing this for now.
    
    [persistentStoreCoordinator executeAction: action inMessage: inMessage completionBlock: completionBlock waitUntilDone: waitUntilDone];
}

@end




