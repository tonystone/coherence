//
//  MGManagedEntity.m
//  Connect
//
//  Created by Tony Stone on 5/6/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGManagedEntity.h"
#import "MGActionQueue.h"
#import "MGWebService.h"
#import "MGTraceLog.h"

#import <CoreData/CoreData.h>

@implementation MGManagedEntity  {
    NSEntityDescription       * entity;
    MGWebService * webService;
    NSString                  * persistentStoreIdentifier;
    NSObject <MGObjectMapper> * objectMapper;

    dispatch_queue_t            synchronizedAccessQueue;
    MGActionQueue             * actionQueue;
}

- (NSEntityDescription *) entity {
    return entity;
}

- (MGWebService *) webService {
    return webService;
}

- (NSObject <MGObjectMapper> *) objectMapper {
    return objectMapper;
}

- (NSString *) persistentStoreIdentifier {
    return persistentStoreIdentifier;
}

- (dispatch_queue_t) synchronizedAccessQueue {
    return synchronizedAccessQueue;
}

- (MGActionQueue *)actionQueue {
    return actionQueue;
}

- (NSDictionary *)remoteIDAttributes {
    return @{};
}

@end

@implementation MGManagedEntity (Initialization)

- (id) initWithEntityDescription:(NSEntityDescription *)anEntity persistentStoreIdentifier: (NSString *) aPersistentStoreIdentifier {
    
    NSParameterAssert(anEntity != nil);
    NSParameterAssert(aPersistentStoreIdentifier != nil);
    
    if ((self = [super init])) {
        entity      = anEntity;

        NSString * queueSuffix = [NSString stringWithFormat: @"%u.%@", [self hash], [anEntity name]];
        
        actionQueue             = [[MGActionQueue alloc] initWithName: queueSuffix mode: MGActionQueueSerial];
        synchronizedAccessQueue = dispatch_queue_create([[@"com.mobilegridinc.queue.synchronizedAccess." stringByAppendingString: queueSuffix] UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void) setObjectMapper:(NSObject<MGObjectMapper> *) newValue {
    
    if (objectMapper != newValue) {
        objectMapper = newValue;
    }
}

- (void) setWebService:(MGWebService *)aWebService {
    
    if (webService != aWebService) {
        webService = aWebService;
    }
}

- (void) setPersistentStoreIdentifier: (NSString *) newValue {
    
    if (persistentStoreIdentifier != newValue) {
        persistentStoreIdentifier = newValue;
    }
}

@end