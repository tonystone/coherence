//
//  MGConnect+Action.m
//  MGConnect
//
//  Created by Tony Stone on 3/28/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnect+EntityAction.h"
#import "MGEntityAction.h"
#import "MGConnect+Private.h"
#import "MGDataStoreManager.h"
#import "MGAssert.h"
#import "MGTraceLog.h"
#import "MGEntityListAction.h"

/**
 */
@implementation MGConnect (EntityAction)

- (void) refreshEntity: (NSEntityDescription *) anEntity where: (NSPredicate *) aPredicateOrNil completionBlock: (MGActionCompletionBlock) completionBlock waitUntilDone: (BOOL) waitUntilDone {

#warning     MGAssertIsNotMainThreadIfCondition(waitUntilDone);
    NSParameterAssert(anEntity != nil);
    //
    // Locate the datastore
    //
    MGDataStoreManager * dataStoreManager = [self dataStoreManagerForEntity: anEntity];
    
    MGEntityListAction * action = [[MGEntityListAction alloc] initWithType: MGEntityActionList entityDescription: anEntity dataStoreManager: dataStoreManager];
    
    [dataStoreManager executeAction: action waitUntilDone: waitUntilDone];
}

#pragma mark - Private methods

- (MGDataStoreManager *) dataStoreManagerForEntity: (NSEntityDescription *) anEntity {
    
    //
    // Lookup the data store responsible for the entity
    //
    MGDataStoreManager * dataStoreManager = CFDictionaryGetValue(((_ICS *)_ics)->dataStoreManagersByModelPointer, (__bridge const void *) [anEntity managedObjectModel]);
    
    if (!dataStoreManager) {
        @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [NSString stringWithFormat: @"Data store for entity \"%@\" not opened. It must be opened before executing actions.", [anEntity name]] userInfo: nil];
    }
    
    return dataStoreManager;
}


@end

