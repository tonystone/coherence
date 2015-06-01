//
// Created by Tony Stone on 4/30/15.
//

#import "CCBackingStore.h"
#import <TraceLog/TraceLog.h>
#import "CCPersistentStoreCoordinator.h"
#import "NSManagedObjectModel+UniqueIdentity.h"

@interface CCBackingStore (private)
    - (void) addPersistentStoreForConfiguration: (NSString *) configurationName  storeType: (NSString *) storeType storePath: (NSString *) storePath;
@end

@implementation CCBackingStore {
        NSManagedObjectModel         * _managedObjectModel;
        NSPersistentStoreCoordinator * _persistentStoreCoordinator;
    }

    - (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)aModel {
        
        LogInfo(@"Initializing '%@' instance...", NSStringFromClass([self class]));
        
        self = [super init];
        if (self) {
            _managedObjectModel = aModel;
            
            NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            
            NSString * storePath = [cachesPath stringByAppendingFormat: @"/Cache%@.bin", [aModel uniqueIdentifier]];
            
            //
            // Create the persistent store _persistentStoreCoordinator
            // so we can attache the persistent stores
            // to it.
            //
            _persistentStoreCoordinator = [[CCPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
            
            [self addPersistentStoreForConfiguration: nil storeType: NSSQLiteStoreType storePath: storePath];
            
            LogInfo(@"'%@' instance initialized.", NSStringFromClass([self class]));
        }
        return self;
    }

    - (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
        return _persistentStoreCoordinator;
    }

    - (NSManagedObjectModel *) managedObjectModel {
        return _managedObjectModel;
    }

    - (void) reset {

        NSError * error = nil;

        //
        // Remove the persistent stores first
        //
        for (NSPersistentStore * aPersistentStore in [_persistentStoreCoordinator persistentStores]) {
            [_persistentStoreCoordinator removePersistentStore:aPersistentStore error:&error];
        }

        _persistentStoreCoordinator = nil;
        _managedObjectModel = nil;
    }

    - (void) clearAllData {

        @autoreleasepool {
            // We want callbacks here but we don't want any other behavior to kick off
            NSManagedObjectContext * editContext = [[NSManagedObjectContext alloc] init];
            [editContext setPersistentStoreCoordinator: [self persistentStoreCoordinator]];

            // Find all root entities
            for (NSEntityDescription * entity in [_managedObjectModel entities]) {
                // If there is no super entity, this is a root entity
                if (![entity superentity]) {
                    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName: [entity name]];

                    NSError * error = nil;

                    NSArray * managedObjects = [editContext executeFetchRequest: fetchRequest error: &error];

                    for (NSManagedObject * aManagedObject in managedObjects) {
                        [editContext deleteObject: aManagedObject];
                    }

                    [editContext save: &error];
                }
            }
        }
    }

@end

@implementation CCBackingStore (private)

    - (void) addPersistentStoreForConfiguration: (NSString *) configurationName  storeType: (NSString *) storeType storePath: (NSString *) storePath {

        NSParameterAssert(storeType != nil);
        NSParameterAssert(storePath != nil);

        NSFileManager * fileManager     = [NSFileManager defaultManager];
        NSURL         * storeUrl        = [NSURL fileURLWithPath: storePath];

        BOOL            removeIncompatibleStore = YES;

        NSError           * error           = nil;
        NSPersistentStore * persistentStore = nil;


        if ([fileManager fileExistsAtPath: storePath]) {

            NSDictionary * metadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType: storeType URL: storeUrl error: &error];

            if (![_managedObjectModel isConfiguration:configurationName compatibleWithStoreMetadata:metadata]) {

                if (removeIncompatibleStore) {

                    LogWarning(@"Removing incompatible persistent store at path %@", storePath);

                    //
                    // If the existing persistentStore is not compatible with the structure
                    // provided, we need to delete it and recreate it.
                    //
                    if (![fileManager removeItemAtPath: storePath error: &error]) {
                        @throw [NSException exceptionWithName: @"PersistentStore Creation Exception" reason: [NSString stringWithFormat: @"%@: Could not remove incompatible persistent store", [error localizedDescription]] userInfo: nil];
                    }

                    LogWarning(@"Persistent store removed");

                } else {
                    @throw [NSException exceptionWithName: @"PersistentStore Creation Exception" reason: @"The existing persistent store is not compatible with the managed object _managedObjectModel" userInfo: nil];
                }
            }
        }

        persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:storeType configuration:configurationName URL:storeUrl options:nil error:&error];

        if (!persistentStore) {

            NSString * errorMessage = [NSString stringWithFormat: @"Failed to add PersistentStore <%@>", configurationName];

            @throw [NSException exceptionWithName: errorMessage reason: [error localizedDescription] userInfo: nil];
        }

#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
        //
        // Check to make sure the protection key is NSFileProtectionComplete
        //
        NSDictionary * currentAttributes = [fileManager attributesOfItemAtPath: storePath error: nil];

        if (currentAttributes[NSFileProtectionKey] != NSFileProtectionComplete) {
            [fileManager setAttributes: @{NSFileProtectionKey: NSFileProtectionComplete} ofItemAtPath: storePath error: nil];
        };
#endif

    }


@end

