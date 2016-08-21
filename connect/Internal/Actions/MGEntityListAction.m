//
//  MGEntityListAction.m
//  MGConnect
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//


#import "MGEntityListAction.h"
#import "MGWebService.h"
#import "MGWebServiceInMessage.h"
#import "MGWebServiceOutMessage.h"
#import "MGWebServiceOperation.h"
#import "MGConnect+PrivateSettings.h"
#import "MGEntityActionDefinition+Private.h"
#import "MGConnect+PrivateSettings.h"
#import "MGObjectMapper.h"
#import "MGResourceReferenceDataMergeOperation.h"
@import TraceLog;
#import "MGLoggedManagedObjectContext.h"

@implementation MGEntityListAction

- (MGActionCompletionStatus) executeInContext: (id) executionContext {
    
    NSParameterAssert([[executionContext class] isSubclassOfClass: [MGLoggedManagedObjectContext class]]);
 
    NSError * error = nil;
    
    MGWebServiceInMessage  * inMessage = [[MGWebServiceInMessage alloc] init];
    MGWebServiceOperation  * operation = [[[self entity] webService] operationForName: [self type]];
    
    //
    // Execute the web service operation
    //
    MGWebServiceOutMessage * outMessage = [operation execute: inMessage];

    if ([outMessage responseData]) {
        LogTrace(2, @"outMessage.responseData: %@", [outMessage responseData]);
        
        NSArray * mergeObjects = [[[self entity] objectMapper] map: [outMessage responseData]];
        
        MGResourceReferenceDataMergeOperation * mergeOperation = [[MGResourceReferenceDataMergeOperation alloc] init];
        
        [mergeOperation mergeObjects: mergeObjects entity: [self entity] subFilter: nil context: executionContext error: &error];
    }

    if (error) {
        [self setError: error];
        
        return MGActionCompletionStatusFailed;
    }
    
    return MGActionCompletionStatusSuccessful;
}

@end
