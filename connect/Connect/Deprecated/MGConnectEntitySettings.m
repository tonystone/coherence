//
//  MGConnect+EntitySettings.m
//  Connect
//
//  Created by Tony Stone on 5/18/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectEntitySettings.h"

#import <objc/runtime.h>

static NSUInteger const DefaultStalenessInterval      = 60;
static BOOL       const DefaultLogTransactions        = YES;
static id         const DefaultPrimaryKeyAttributes   = nil;

id getAssociatedObjectOrModelOverride(id object, void * key) {
    
    id value = objc_getAssociatedObject(object, key);
    if (!value) {
        value = objc_getAssociatedObject([object managedObjectModel], key);
        if (!value) {
            return nil;
        }
    }
    return value;
}

static void * const kStalenessIntervalKey = (void*)&kStalenessIntervalKey;
static void * const kLogTransactions      = (void*)&kLogTransactions;
static void * const kPrimaryKeyAttributes = (void*)&kPrimaryKeyAttributes;

@implementation NSEntityDescription (MGEntitySettings)

#pragma mark stalenessInterval

- (void) setStalenessInterval:(NSUInteger)stalenessInterval {
    objc_setAssociatedObject(self, kStalenessIntervalKey,  [NSNumber numberWithUnsignedInteger: stalenessInterval], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger) stalenessInterval {
    id value = getAssociatedObjectOrModelOverride(self, kStalenessIntervalKey);
    
    if (!value) return DefaultStalenessInterval;
    
    return [value unsignedIntegerValue];
}

#pragma mark logTransactions

- (void) setLogTransactions:(BOOL) logTransactions {
    objc_setAssociatedObject(self, kLogTransactions,  [NSNumber numberWithBool: logTransactions], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL) logTransactions {
    id value = getAssociatedObjectOrModelOverride(self, kLogTransactions);
    
    if (!value) return DefaultLogTransactions;
    
    return [value unsignedIntegerValue];
}

@end


@implementation NSManagedObjectModel (MGEntitySettings)

#pragma mark stalenessInterval

- (void) setStalenessInterval:(NSUInteger)stalenessInterval {
    objc_setAssociatedObject(self, kStalenessIntervalKey,  [NSNumber numberWithUnsignedInteger: stalenessInterval], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger) stalenessInterval {
    id value = objc_getAssociatedObject(self, kStalenessIntervalKey);
    
    if (!value) return DefaultStalenessInterval;
    
    return [value unsignedIntegerValue];
}

#pragma mark logTransactions

- (void) setLogTransactions:(BOOL) logTransactions {
    objc_setAssociatedObject(self, kLogTransactions,  [NSNumber numberWithBool: logTransactions], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL) logTransactions {
    id value = objc_getAssociatedObject(self, kLogTransactions);
    
    if (!value) return DefaultLogTransactions;
    
    return [value unsignedIntegerValue];
}

#pragma mark logTransactions

- (void) setRemoteIDAttributes:(NSArray *) remoteIDAttributes {
    objc_setAssociatedObject(self, kPrimaryKeyAttributes,  remoteIDAttributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *) remoteIDAttributes {
    id value = objc_getAssociatedObject(self, kPrimaryKeyAttributes);
    
    if (!value) return DefaultPrimaryKeyAttributes;
    
    return value;
}

@end
