//
//  MGEntityAction.m
//  MGConnect
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGEntityAction.h"
@import TraceLog;
#import "MGConnect+EntityAction.h"
#import "MGDataStoreManager.h"

/**
 */
@implementation MGEntityAction  {
    NSEntityDescription * entity;
    MGDataStoreManager * dataStoreManager;
}

- (NSEntityDescription *) entity {
    return entity;
}

- (MGActionCompletionStatus) executeInContext: (NSManagedObjectContext *) executionContext {
    [self doesNotRecognizeSelector: _cmd];
    return MGActionCompletionStatusFailed;
}

- (void) start {
    [self executionStarted];
    
    if (![self isCancelled]) {
        [self executionEnded: [self executeInContext: [dataStoreManager editManagedObjectContext]]];
    } else {
        [self executionEnded: MGActionCompletionStatusCancelled];
    }
}

@end

@implementation MGEntityAction (Initialization)

- (id) initWithType: (NSString *) anActionType entityDescription: (NSEntityDescription *) anEntityDescription dataStoreManager: (MGDataStoreManager *) aDataStoreManager {
    
    NSParameterAssert(anActionType != nil);
    NSParameterAssert(anEntityDescription != nil);
    NSParameterAssert(aDataStoreManager != nil);
    
    if ((self = [super initWithType: anActionType])) {
        entity           = anEntityDescription;
        dataStoreManager = aDataStoreManager;
    }
    return self;
}

@end

