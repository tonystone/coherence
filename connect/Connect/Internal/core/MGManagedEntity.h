//
//  MGManagedEntity.h
//  Connect
//
//  Created by Tony Stone on 5/6/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSEntityDescription;
@class MGWebService;

@protocol MGEntityActionNotificationDelegate;
@protocol MGObjectMapper;

@class MGActionQueue;
@class MGFetchRequestAnalyzer;

/**
 Note: this is a low level structure used to store the information 
       about a managed entity.
 */
@interface MGManagedEntity : NSObject

- (NSEntityDescription *)       entity;
- (NSString *)                  persistentStoreIdentifier;

- (dispatch_queue_t)            synchronizedAccessQueue;
- (MGActionQueue *)             actionQueue;

- (MGWebService *)       webService;
- (NSObject <MGObjectMapper> *) objectMapper;

- (NSDictionary *) remoteIDAttributes;

@end


@interface MGManagedEntity (Initialization)

- (id) initWithEntityDescription: (NSEntityDescription *) anEntity persistentStoreIdentifier: (NSString *) aPersistentStoreIdentifier;

- (void) setWebService: (MGWebService *) aWebService;
- (void) setObjectMapper: (NSObject <MGObjectMapper> *) anObjectMapper;

@end