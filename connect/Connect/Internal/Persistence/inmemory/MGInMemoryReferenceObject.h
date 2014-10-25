//
//  MGReferenceObjectNode.h
//  Connect2
//
//  Created by Tony Stone on 6/4/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MGReferenceObjectID;
@class NSManagedObject;
@class NSIncrementalStoreNode;
@class NSManagedObjectID;
@class NSRelationshipDescription;

@interface MGInMemoryReferenceObject : NSObject

- (id) initWithObjectID: (NSManagedObjectID *) anObjectID values: (NSDictionary *) values version: (uint64_t) version;
- (id) initWithObject: (NSManagedObject *) anObject version: (uint64_t) version;

- (void) updateWithValues: (NSDictionary *) values version: (uint64_t) version;
- (void) updateAttributesWithObject: (NSManagedObject *) managedObject version:(uint64_t) newVersion;

- (NSDictionary *) attributeValuesAndKeys;
- (id) relationshipFaultValue: (NSRelationshipDescription *) relationship;

- (void) setPrimitiveValue: (id) value forKey: (id <NSCopying>) key;
- (id) primitiveValueForKey:(NSString *)key;

- (NSManagedObjectID *) objectID;
- (NSDictionary *) values;
- (uint64_t) version;

@end
