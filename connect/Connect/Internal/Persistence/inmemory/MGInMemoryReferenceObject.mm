//
//  MGReferenceObjectNode.m
//  Connect2
//
//  Created by Tony Stone on 6/4/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGInMemoryReferenceObject.h"
#import <CoreData/CoreData.h>

@implementation MGInMemoryReferenceObject {
    NSManagedObjectID * objectID;
    NSMutableDictionary * values;
    uint64_t              version;
}

- (id) initWithObjectID: (NSManagedObjectID *) anObjectID values: (NSDictionary *) theValues version: (uint64_t) aVersion {
    
    if ((self = [super init])) {
        objectID = anObjectID;
        values   = [[NSMutableDictionary alloc] initWithDictionary: theValues];
        version  = aVersion;
    }
    return self;
}

- (id) initWithObject: (NSManagedObject *) anObject version: (uint64_t) aVersion {
    
    if ((self = [super init])) {

        objectID = [anObject objectID];
        values   = [[NSMutableDictionary alloc] init];

        [self updateAttributesWithObject: anObject version: aVersion];
    }
    return self;
}

- (void)updateWithValues:(NSDictionary *) newValues version:(uint64_t) newVersion {

    if (values != newValues) {
        values = [[NSMutableDictionary alloc] initWithDictionary: newValues];
    }
    // Not worth testing version, just assign
    version = newVersion;
}

- (void) updateAttributesWithObject: (NSManagedObject *) managedObject version:(uint64_t) newVersion {
    
    NSArray  * attributes = [[[managedObject entity] attributesByName] allKeys];
    //
    // Only take the none nil attributes, skip all relationships
    //
    for (NSString * attribute in attributes) {
        id value = [managedObject primitiveValueForKey: attribute];
        
        if (value) {
            [values setObject: value forKey: attribute];
        }
    }
    
    version  = newVersion;
}

- (NSDictionary *)attributeValuesAndKeys {
    NSArray             * attributes             = [[[objectID entity] attributesByName] allKeys];
    NSMutableDictionary * attributeValuesAndKeys = [[NSMutableDictionary alloc] initWithCapacity: [attributes count]];
    
    for (NSString * attribute in attributes) {
        id value = [values objectForKey: attribute];
        
        if (value) {
            [attributeValuesAndKeys setObject: value forKey: attribute];
        }
    }
    return attributeValuesAndKeys;
}

- (id) relationshipFaultValue:(id)relationship {
    id relationshipValue = [values objectForKey: [relationship name]];
    
    id result = nil;
    
    if ([relationship isToMany]) {
        result = [[NSMutableSet alloc] init];
        
        for (MGInMemoryReferenceObject * referenceObject in relationshipValue) {
            [result addObject: [referenceObject objectID]];
        }
    } else {
        if (relationshipValue) {
            result = [relationshipValue objectID];
        } else {
            result = [NSNull null];
        }
    }
    return result;
}

- (NSManagedObjectID *) objectID {
    return objectID;
}

- (void) setPrimitiveValue: (id) value forKey: (id <NSCopying>) key {
    [values setObject: value forKey: key];    
}

- (id) primitiveValueForKey:(NSString *)key {
    return [values objectForKey: key];    
}

- (NSDictionary *) values {
    return values;
}

- (uint64_t) version {
    return version;
}

#pragma mark - Used by predicate execution indirectly

- (void) setValue: (id) value forKey: (NSString *) key {
    [self willChangeValueForKey: key];
    [values setObject: value forKey: key];
    [self didChangeValueForKey: key];
}

- (id) valueForKey:(NSString *)key {
    return [values objectForKey: key];
}

@end
