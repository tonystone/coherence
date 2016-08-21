//
//  MGBackingStore.h
//  CloudScope
//
//  Created by Tony Stone on 2/21/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString * MGBackingStoreType;

extern MGBackingStoreType const MGBackingStoreTypeMetadata;
extern MGBackingStoreType const MGBackingStoreTypeDataCache;

#define kDefaultConfiguration @"__mgdefault__"
#define kDefaultStoreType NSSQLiteStoreType

extern NSString * const MGRemoveIncompatibleStoreOption;
extern NSString * const MGPersistentStoreTypeStoreKey;
extern NSString * const MGPersistentStoreGroupIDStoreKey;
extern NSString * const MGPersistentStoreInstanceIDStoreKey;
extern NSString * const MGPersistentStoreDataInitializerClassStoreKey;

@class NSPersistentStoreCoordinator;
@class NSManagedObjectModel;
@class NSManagedObjectContext;
@class MGManagedObjectContext;

@interface MGBackingStore : NSObject {
@protected
    __block NSPersistentStoreCoordinator * persistentStoreCoordinator;
    __block NSManagedObjectModel         * managedObjectModel;
}

- (id) initWithType: (MGBackingStoreType) aStoreType managedObjectModel: (NSManagedObjectModel *) aManagedObjectModel storagePath: (NSString *) aStoragePath options: (NSDictionary *) options;

- (NSManagedObjectModel *)   managedObjectModel;

- (void) reset;
- (void) clearAllData;

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator;

- (NSString *) extensionForStoreType: (NSString *) storeType;

@end
