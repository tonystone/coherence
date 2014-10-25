//
//  MGConnectPersistentStoreCoordinator__Internal_+___VARIABLE_productName:identifier___.m
//  Connect
//
//  Created by Tony Stone on 9/3/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectPersistentStoreCoordinator+Internal.h"
#import "MGConnectEntityAction.h"

@implementation MGConnectPersistentStoreCoordinator (Internal)
#pragma mark - Entity Management

    - (void) removeManageEntity: (NSEntityDescription *) anEntity {

        NSParameterAssert(anEntity != nil);

#warning FIXME - Code removed.
//    MGConnectPersistentStore * connectPersistentStore = [connectPersistentStoresByEntityName objectForKey: [anEntity name]];
//
//    if (!connectPersistentStore) {
//         @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [NSString stringWithFormat: @"Entity \"%@\" does not have an NSPersistentStore associated with it for the NSPersistentStoreCoordinator specified", [anEntity name]] userInfo: nil];
//    }
//
//    LogInfo(@"Removing managed entity \"%@\"...", [anEntity name]);
//
//    [connectPersistentStore removeManageEntity: anEntity];
//
//    LogInfo(@"Managed entity \"%@\" removed", [anEntity name]);
    }

    - (void) addManageEntity: (NSEntityDescription *) anEntity actionDefinition: (id <MGConnectEntityActionDefinition>) anActionDefinition {

        NSParameterAssert(anEntity != nil);
        NSParameterAssert(anActionDefinition != nil);

#warning FIXME - Code removed.
//    MGConnectPersistentStore * connectPersistentStore = [connectPersistentStoresByEntityName objectForKey: [anEntity name]];
//
//    if (!connectPersistentStore) {
//        @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [NSString stringWithFormat: @"Entity \"%@\" does not have an NSPersistentStore associated with it for the NSPersistentStoreCoordinator specified, entity cannot be managed until a NSPersistentStore is added for this entity", [anEntity name]] userInfo: nil];
//    }
//
//    [connectPersistentStore addManageEntity: anEntity actionDefinition: anActionDefinition];
    }

#pragma mark Action Management

    - (MGConnectEntityAction *) registeredEntityAction:(NSString *) anActionName entity:(NSEntityDescription *) anEntity {

        NSParameterAssert(anEntity != nil);
        NSParameterAssert(anActionName != nil);

#warning FIXME - Code removed.
//
//    MGConnectPersistentStore * connectPersistentStore = [connectPersistentStoresByEntityName objectForKey: [anEntity name]];
//
//    if (!connectPersistentStore) {
//        @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [NSString stringWithFormat: @"Entity \"%@\" does not have an NSPersistentStore associated with it for the NSPersistentStoreCoordinator specified", [anEntity name]] userInfo: nil];
//    }
//
//    return [connectPersistentStore registeredEntityAction: anActionName entity: anEntity];
        return nil;
    }

#pragma mark Action Execution

    - (void) executeAction: (id <MGConnectAction>) action inMessage: (MGConnectActionMessage *) inMessage completionBlock: (MGConnectActionCompletionBlock) completionBlock waitUntilDone: (BOOL) waitUntilDone {

        NSParameterAssert(action != nil);
        NSParameterAssert(inMessage != nil);

        if ([action conformsToProtocol: @protocol(MGConnectEntityAction)]) {
            id <MGConnectEntityAction> entityAction = (id <MGConnectEntityAction>) action;

#warning FIXME - Code removed.
//        MGConnectPersistentStore * connectPersistentStore = [connectPersistentStoresByEntityName objectForKey: [[entityAction entity] name]];
//
//        if (!connectPersistentStore) {
//            @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [NSString stringWithFormat: @"Entity \"%@\" does not have an NSPersistentStore associated with it for the NSPersistentStoreCoordinator specified", [[entityAction entity] name]] userInfo: nil];
//        }
//
//        [connectPersistentStore executeEntityAction: entityAction inMessage: inMessage completionBlock: completionBlock waitUntilDone: waitUntilDone];
//        } else {
//
//            MGActionExecutionProxy * actionProxy = [MGActionExecutionProxy actionExecutionProxyForAction: action inMessage: inMessage persistentStoreCoordinator: self completionBlockWithStatus: completionBlock];
//
//            [defaultActionQueue executeActionProxy: actionProxy waitUntilDone: waitUntilDone];
        }
    }

    - (BOOL) isEntityManaged: (NSEntityDescription *) anEntity  {

        NSParameterAssert(anEntity != nil);

#warning FIXME - Code removed.
//    MGConnectPersistentStore * connectPersistentStore = [connectPersistentStoresByEntityName objectForKey: [anEntity name]];
//
//    if (!connectPersistentStore) {
//        return NO;
//    }
//    return [connectPersistentStore isEntityManaged: anEntity];
        return NO;
    }

    - (MGManagedEntity *) managedEntity: (NSEntityDescription *) anEntity  {

        NSParameterAssert(anEntity != nil);

#warning FIXME - Code removed.
//
//    MGConnectPersistentStore * connectPersistentStore = [connectPersistentStoresByEntityName objectForKey: [anEntity name]];
//
//    if (!connectPersistentStore) {
//        @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [NSString stringWithFormat: @"Entity \"%@\" does not have an NSPersistentStore associated with it for the NSPersistentStoreCoordinator specified", [anEntity name]] userInfo: nil];
//    }
//    return [connectPersistentStore managedEntity: anEntity];
        return nil;
    }
@end



