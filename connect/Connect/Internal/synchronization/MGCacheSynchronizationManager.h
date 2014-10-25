//
//  MGCacheSynchronizationManager.h
//  Connect
//
//  Created by Tony Stone on 5/28/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSFetchRequest;
@class MGManagedEntity;
@class MGConnectPersistentStoreCoordinator;
@class MGFetchRequestAnalyzer;

@interface MGCacheSynchronizationManager : NSObject

+ (MGCacheSynchronizationManager *) sharedManager;

- (void) processFetchRequest: (NSFetchRequest *) fetchRequest fetchAnalyzer: (MGFetchRequestAnalyzer *) fetchAnalyzer managedEntity: (MGManagedEntity *) managedEntity forPersistentStoreCoordinator: (MGConnectPersistentStoreCoordinator *) persistentStoreCoordinator;

@end
