//
//  MGConnectManagedObjectActionMessage.m
//  Connect
//
//  Created by Tony Stone on 5/28/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectManagedObjectActionMessage.h"
#import <CoreData/CoreData.h>

@implementation MGConnectManagedObjectActionMessage {
    NSManagedObjectID * objectID;
    NSString          * persistentStoreIdentifier;
    NSArray           * updatedValueKeys;
    NSDictionary      * valuesAndKeys;
}

- (id) initWithManagedObject:(NSManagedObject *)aManagedObject {

    NSParameterAssert(aManagedObject != nil);

    if ((self = [super init])) {
        objectID = [aManagedObject objectID];
        
        if (![objectID isTemporaryID]) {
            persistentStoreIdentifier = [[objectID persistentStore] identifier];
        }
        updatedValueKeys = [[aManagedObject changedValues] allKeys];
        valuesAndKeys    = [aManagedObject dictionaryWithValuesForKeys: [[[aManagedObject entity] attributesByName] allKeys]];
    }
    return self;
}

- (NSArray *) updatedValueKeys {
    return updatedValueKeys;
}

- (NSDictionary *)valuesAndKeys {
    return valuesAndKeys;
}

@end
