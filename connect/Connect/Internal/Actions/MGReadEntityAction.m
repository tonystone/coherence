//
//  MGEntityReadAction.m
//  MGConnect
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGReadEntityAction.h"

#import "MGTraceLog.h"
#import "MGConnectEntityActionDefinition.h"
#import "MGConnectActionMessage.h"
#import "MGConnectEntitySettings.h"
#import "MGWebService.h"
#import "MGWebServiceInMessage.h"
#import "MGWebServiceOutMessage.h"
#import "MGWebServiceOperation.h"

#import "MGConnectManagedObjectContext+Internal.h"
#import "MGConnectPersistentStoreCoordinator.h"
#import "MGEntitySettings.h"
#import "MGManagedEntity.h"

#import "MGObjectMapper.h"
#import "MGDataMergeOperation.h"

#import "MGManagedEntity.h"
#import "MGObjectMapper.h"

@implementation MGReadEntityAction {
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
    //
    // We must translate from the MGConnectActionMessage to the MGWebServiceInMessae type
    // before excuting the webService.
    //
    MGWebServiceInMessage * webServiceInMessage = [[MGWebServiceInMessage alloc] init];
    [webServiceInMessage setParametersWithDictionary: [inMessage valuesAndKeys]];
    
    // Execute the web service operation
    MGWebServiceOutMessage * outMessage = [webServiceOperation execute: webServiceInMessage];
    
    //
    // If there was data returned, process it.
    //
    if ([outMessage responseData]) {
        LogTrace(2, @"outMessage.responseData: %@", [outMessage responseData]);
        
        NSArray * mergeObjects = [objectMapper map: [outMessage responseData]];
        
        MGConnectManagedObjectContext * context = [[MGConnectManagedObjectContext alloc] initSynchronized: NO logged: NO connectManaged: NO];
        [context setPersistentStoreCoordinator: persistentStoreCoordinator];
        
        MGDataMergeOperation * mergeOperation = [[MGDataMergeOperation alloc] init];
        
        //
        // Since this is a single read, we must create
        // a subFilter that will limit the merges scope to
        // just the one target object.
        //
        NSMutableArray  * comparisonPredicates = [[NSMutableArray alloc] init];
        
#warning FIXME - Code removed.
        for (NSString * key in (NSArray *) nil /* [[managedEntity entity] remoteIDAttributes] */) {
            id value = [[inMessage valuesAndKeys] objectForKey: key];
            
            NSAssert(value != nil, @"nil key value found during creation of subFilter for merge operation");
            if (!value) {
                // Throw
            }
            [comparisonPredicates addObject: [NSPredicate predicateWithFormat: @"%K == %@", key, value]];
        }
        
        NSPredicate * subFilter = nil;
        
        if ([comparisonPredicates count] > 1) {
            subFilter = [[NSCompoundPredicate alloc] initWithType: NSAndPredicateType subpredicates: comparisonPredicates];
        } else {
            subFilter = [comparisonPredicates lastObject];
        }
        
        //
        // Now perform the merge
        //
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
