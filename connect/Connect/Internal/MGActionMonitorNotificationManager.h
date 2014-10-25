//
//  MGActionDelegateNotificationManager.h
//  Connect
//
//  Created by Tony Stone on 5/24/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MGConnectActionMonitor;
@class MGConnectPersistentStoreCoordinator;
@class NSEntityDescription;

@interface MGActionMonitorNotificationManager : NSObject

+ (MGActionMonitorNotificationManager *) sharedManager;

- (void) registerActionMonitor: (id <MGConnectActionMonitor>) monitor;
- (void) registerActionMonitor: (id <MGConnectActionMonitor>) monitor forEntity: (NSEntityDescription *) entity;

@end
