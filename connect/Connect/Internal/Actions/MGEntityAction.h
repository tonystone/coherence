//
//  MGEntityAction.h
//  MGConnect
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGAction.h"
#import "MGConnect+EntityAction.h"

@class NSEntityDescription;
@protocol MGObjectMapper;

@interface MGEntityAction : MGAction <MGEntityAction>

    /**
     Return the entity that this EntityAction is targeting
     */
    - (NSEntityDescription *) entity;

    /**
     Return the mapper for this entity
     */
    - (NSObject <MGObjectMapper> *) objectMapper;

    /**
     Main execution metho which starts this particular web service
     
     NOTE: You must override this method.  Do NOT override start from NSOperation.
     */
    - (MGActionCompletionStatus) executeInContext: (NSManagedObjectContext *) executionContext;

@end

@class MGDataStoreManager;

@interface MGEntityAction (Initialization)

- (id) initWithType: (NSString *) anActionType entityDescription: (NSEntityDescription *) anEntityDescription dataStoreManager: (MGDataStoreManager *) aDataStoreManager;

@end