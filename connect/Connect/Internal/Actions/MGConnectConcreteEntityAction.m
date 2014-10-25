//
//  MGConnectConcreteEntityAction.m
//  Connect
//
//  Created by Tony Stone on 5/27/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectConcreteEntityAction.h"

#import "MGTraceLog.h"
#import "MGConnectAction.h"

#import "MGConnectEntityActionDefinition.h"
#import "MGListEntityAction.h"
#import "MGReadEntityAction.h"
#import "MGCreateEntityAction.h"
#import "MGUpdateEntityAction.h"
#import "MGDeleteEntityAction.h"

#import "MGManagedEntity.h"
#import "MGWebService.h"

@implementation MGConnectConcreteEntityAction

+ (MGConnectEntityAction *) entityAction: (NSString *) actionName managedEntity: (MGManagedEntity *) managedEntity {
    
    MGConnectEntityAction * action;
    MGWebServiceOperation * operation = [[managedEntity webService] operationForName: actionName];
    
    NSAssert(operation != nil, @"Failed to locate a MGWebServiceOperation for \"%@\"", actionName);
    
    if      (actionName == MGEntityActionTypeList)   action = [[MGListEntityAction alloc]    initWithName: actionName entity: [managedEntity entity] webServiceOperation: operation manaagedEntity: managedEntity];
    else if (actionName == MGEntityActionTypeRead)   action = [[MGReadEntityAction alloc]    initWithName: actionName entity: [managedEntity entity] webServiceOperation: operation manaagedEntity: managedEntity];
    else if (actionName == MGEntityActionTypeCreate) action = [[MGCreateEntityAction alloc]  initWithName: actionName entity: [managedEntity entity] webServiceOperation: operation];
    else if (actionName == MGEntityActionTypeUpdate) action = [[MGUpdateEntityAction alloc]  initWithName: actionName entity: [managedEntity entity] webServiceOperation: operation];
    else if (actionName == MGEntityActionTypeDelete) action = [[MGDeleteEntityAction alloc]  initWithName: actionName entity: [managedEntity entity] webServiceOperation: operation];
    else                                             action = [[self alloc]                  initWithName: actionName entity: [managedEntity entity] webServiceOperation: operation];
    
    return action;
}

- (id) init {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (id) initWithName:(NSString *)name {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (id) initWithName:(NSString *)name entity:(NSEntityDescription *)entity {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (id) initWithName:(NSString *)name entity: (NSEntityDescription *) anEntity webServiceOperation: (MGWebServiceOperation *) aWebServiceOperation {
    
    if ((self = [super initWithName: name entity: anEntity])) {
        webServiceOperation = aWebServiceOperation;
    }
    return self;
}

@end
