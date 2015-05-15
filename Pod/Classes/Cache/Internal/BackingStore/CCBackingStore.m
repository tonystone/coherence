//
// Created by Tony Stone on 4/30/15.
//

#import "CCBackingStore.h"
#import <TraceLog/TraceLog.h>

@interface CCBackingStore (private)
    - (void) handleContextDidSaveNotification: (NSNotification *) notification;
    - (void) addPersistentStoreForConfiguration: (NSString *) configurationName  storeType: (NSString *) storeType storePath: (NSString *) storePath;
@end

@implementation CCBackingStore {
        NSManagedObjectModel         * managedObjectModel;
        NSPersistentStoreCoordinator * persistentStoreCoordinator;
    }

    - (instancetype)initWithIdentifier: (NSString *) anIdentifier managedObjectModel:(NSManagedObjectModel *) aModel {
        self = [super init];
        if (self) {
            managedObjectModel = aModel;
            
            LogInfo(@"Creating persistentStoreCoordinator for '%@'...", anIdentifier);
            
            NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            
            NSString * storePath = [cachesPath stringByAppendingFormat: @"/%@.bin", anIdentifier];
            
            //
            // Create the persistent store persistentStoreCoordinator
            // so we can attache the persistent stores
            // to it.
            //
            persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
            
            [self addPersistentStoreForConfiguration: nil storeType: NSSQLiteStoreType storePath: storePath];
            
            LogInfo(@"PersistentStoreCoordinator '%@' created.", anIdentifier);
        }
        return self;
    }

    - (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
        return persistentStoreCoordinator;
    }

    - (NSManagedObjectModel *) managedObjectModel {
        return managedObjectModel;
    }

    - (void) reset {

        NSError * error = nil;

        //
        // Remove the persistent stores first
        //
        for (NSPersistentStore * aPersistentStore in [persistentStoreCoordinator persistentStores]) {
            [persistentStoreCoordinator removePersistentStore: aPersistentStore error: &error];
        }

        persistentStoreCoordinator     = nil;
        managedObjectModel             = nil;
    }

    - (void) clearAllData {

        @autoreleasepool {
            // We want callbacks here but we don't want any other behavior to kick off
            NSManagedObjectContext * editContext = [[NSManagedObjectContext alloc] init];
            [editContext setPersistentStoreCoordinator: [self persistentStoreCoordinator]];

            // Find all root entities
            for (NSEntityDescription * entity in [self.managedObjectModel entities]) {
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

    - (void) handleContextDidSaveNotification: (NSNotification *) notification {
        ; // Default does nothing
    }

    - (void) addPersistentStoreForConfiguration: (NSString *) configurationName  storeType: (NSString *) storeType storePath: (NSString *) storePath {

        NSParameterAssert(storeType != nil);
        NSParameterAssert(storePath != nil);
        
        LogInfo(@"Attaching persistent store...");

        NSFileManager * fileManager     = [NSFileManager defaultManager];
        NSURL         * storeUrl        = [NSURL fileURLWithPath: storePath];

        BOOL            removeIncompatibleStore = YES;

        NSError           * error           = nil;
        NSPersistentStore * persistentStore = nil;


        if ([fileManager fileExistsAtPath: storePath]) {

            NSDictionary * metadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType: storeType URL: storeUrl error: &error];

            if (![managedObjectModel isConfiguration: configurationName compatibleWithStoreMetadata: metadata]) {

                if (removeIncompatibleStore) {

                    LogTrace(1, @"Removing incompatible persistent store at path %@", storePath);

                    //
                    // If the existing persistentStore is not compatible with the structure
                    // provided, we need to delete it and recreate it.
                    //
                    if (![fileManager removeItemAtPath: storePath error: &error]) {
                        @throw [NSException exceptionWithName: @"PersistentStore Creation Exception" reason: [NSString stringWithFormat: @"%@: Could not remove incompatible persistent store", [error localizedDescription]] userInfo: nil];
                    }

                    LogTrace(1, @"Persistent store removed");

                } else {
                    @throw [NSException exceptionWithName: @"PersistentStore Creation Exception" reason: @"The existing persistent store is not compatible with the managed object managedObjectModel" userInfo: nil];
                }
            }
        }

        persistentStore = [persistentStoreCoordinator addPersistentStoreWithType: storeType configuration: configurationName URL: storeUrl options: nil error:&error];

        if (!persistentStore) {

            NSString * errorMessage = [NSString stringWithFormat: @"Failed to add PersistentStore <%@>", configurationName];

            @throw [NSException exceptionWithName: errorMessage reason: [error localizedDescription] userInfo: nil];
        }

        LogInfo(@"Persistent Store attached at %@.", storePath);

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

