//
//  MGListEntityAction.m
//  MGConnect
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGListEntityAction.h"

#import "MGTraceLog.h"
#import "MGConnectEntityActionDefinition.h"
#import "MGWebService.h"
#import "MGWebServiceInMessage.h"
#import "MGWebServiceOutMessage.h"
#import "MGWebServiceOperation.h"

#import "MGConnectManagedObjectContext+Internal.h"
#import "MGConnectPersistentStoreCoordinator.h"
#import "MGEntitySettings.h"
#import "MGManagedEntity.h"
#import "MGConnectActionMessage.h"

#import "MGObjectMapper.h"
#import "MGDataMergeOperation.h"

#import "MGManagedEntity.h"
#import "MGObjectMapper.h"

@implementation MGListEntityAction {
    MGManagedEntity    * managedEntity;
    id <MGObjectMapper> objectMapper;
}

- (id) initWithName:(NSString *)name entity: (NSEntityDescription *) anEntity webServiceOperation: (MGWebServiceOperation *) aWebServiceOperation manaagedEntity:(MGManagedEntity *)aManagedEntity {
    
    if ((self = [super initWithName: name entity: anEntity webServiceOperation:aWebServiceOperation])) {
        managedEntity = aManagedEntity;
        objectMapper  = [aManagedEntity objectMapper];
    }
    return self;
}

- (MGConnectActionCompletionStatus) execute:(id) persistentStoreCoordinator inMessage: (MGConnectActionMessage *) inMessage error:(NSError *__autoreleasing *)error {
    
    NSParameterAssert(persistentStoreCoordinator != nil);
    NSParameterAssert([persistentStoreCoordinator isKindOfClass: [MGConnectPersistentStoreCoordinator class]]);
    NSParameterAssert(inMessage != nil);
    
    NSError * localError = nil;
    
    MGWebServiceInMessage * webServiceInMessage = [[MGWebServiceInMessage alloc] init];
    
    [webServiceInMessage setParametersWithDictionary: [inMessage valuesAndKeys]];
    
    //
    // Execute the web service operation
    //
    MGWebServiceOutMessage * outMessage = [webServiceOperation execute: webServiceInMessage];
    
    if ([outMessage responseData]) {
        LogTrace(2, @"outMessage.responseData: %@", [outMessage responseData]);
        
        NSArray * mergeObjects = [objectMapper map: [outMessage responseData]];
        
        MGConnectManagedObjectContext * context = [[MGConnectManagedObjectContext alloc] initSynchronized: NO logged: NO connectManaged: NO];
        [context setPersistentStoreCoordinator: persistentStoreCoordinator];
        
        MGDataMergeOperation * mergeOperation = [[MGDataMergeOperation alloc] init];

        [mergeOperation mergeObjects: mergeObjects managedEntity: managedEntity subFilter: nil context: context error: &localError];
    }
    
    if (localError) {
        if (error) {
            *error = localError;
        }
        return MGConnectActionCompletionStatusFailed;
    }
    
    return MGConnectActionCompletionStatusSuccessful;
}

@end
