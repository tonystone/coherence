//
//  MGCacheSynchronizationManager.m
//  Connect
//
//  Created by Tony Stone on 5/28/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGCacheSynchronizationManager.h"
#import "MGConnectPersistentStoreCoordinator+Internal.h"
#import "MGConnectEntityAction.h"
#import "MGConnectActionMessage.h"
#import "MGManagedEntity.h"
#import "MGRESTfulFetchRequestAnalyzer.h"
#import "MGTraceLog.h"

@implementation MGCacheSynchronizationManager

static MGCacheSynchronizationManager * sharedManager;

+ (void) initialize {
    
    if (self == [MGCacheSynchronizationManager class]) {
        sharedManager = [[self alloc] init];
    }
}

+ (MGCacheSynchronizationManager *) sharedManager {
    return sharedManager;
}

- (id) init {
    if ((self = [super init])) {
        //
    }
    return self;
}

- (void) processFetchRequest: (NSFetchRequest *) fetchRequest fetchAnalyzer: (MGFetchRequestAnalyzer *) fetchAnalyzer managedEntity: (MGManagedEntity *) managedEntity forPersistentStoreCoordinator: (MGConnectPersistentStoreCoordinator *) persistentStoreCoordinator {
    
    dispatch_async([managedEntity synchronizedAccessQueue], ^{
        
        LogInfo(@"Proccessing fetchRequest <%@ : %p>...", NSStringFromClass([fetchRequest class]), fetchRequest);
        
        MGFetchRequestAnalysis * analysis = [fetchAnalyzer analyze: fetchRequest];
        
        LogInfo(@"FetchRequest analysis\r\r%@\r\r%@", fetchRequest, analysis);
        
        switch ([analysis fetchType]) {
            case MGFetchTypeEntity:
            {
                MGConnectEntityAction  * action    = [persistentStoreCoordinator registeredEntityAction: MGEntityActionTypeList entity: [managedEntity entity]];
                MGConnectActionMessage * inMessage = [MGConnectActionMessage actionMessage];
                
                [persistentStoreCoordinator executeAction: action inMessage: inMessage completionBlock: nil waitUntilDone: YES];
                break;
            }
            case MGFetchTypeObject:
            {
#warning FIXME - Code removed.
                NSString * keyAttribute = nil; // [[[managedEntity entity] remoteIDAttributes] lastObject];
                
                MGConnectEntityAction  * action    = [persistentStoreCoordinator registeredEntityAction: MGEntityActionTypeRead entity: [managedEntity entity]];
                MGConnectActionMessage * inMessage = [MGConnectActionMessage actionMessageWithDictionary: @{keyAttribute: [analysis analysisObjectForKey: keyAttribute]} updatedValueKeys: @[]];
                
                [persistentStoreCoordinator executeAction: action inMessage: inMessage completionBlock: nil waitUntilDone: YES];
                break;
            }
            case MGFetchTypeRelationship:
                
                break;
                
            case MGFetchTypeUnknown:
            default:
                break;
        }
    

    });
}

@end
