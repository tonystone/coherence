//
// Created by Tony Stone on 9/2/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGConnectPersistentStoreCoordinator.h"
#import "MGConnectActionExecutionInfo.h"

@protocol MGConnectEntityActionDefinition;
@protocol MGConnectActionMonitor;
@protocol MGConnectAction;
@class    MGManagedEntity;
@class    MGConnectEntityAction;
@class    MGConnectActionMessage;

@interface MGConnectPersistentStoreCoordinator (Internal)

    - (void) addManageEntity: (NSEntityDescription *) anEntity actionDefinition: (id <MGConnectEntityActionDefinition>) anActionDefinition;

    - (MGManagedEntity *) managedEntity: (NSEntityDescription *) entity;

    - (MGConnectEntityAction *) registeredEntityAction:(NSString *) anActionName entity:(NSEntityDescription *) anEntity ;

    - (void) executeAction: (id <MGConnectAction>) action inMessage: (MGConnectActionMessage *) inMessageOrNil completionBlock: (MGConnectActionCompletionBlock) completionBlock waitUntilDone: (BOOL) waitUntilDone;

@end