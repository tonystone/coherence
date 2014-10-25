//
//  MGMetadataBackingStore.m
//  Connect
//
//  Created by Tony Stone on 5/2/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGMetadataBackingStore.h"

#import <CoreData/CoreData.h>

#import "MGTraceLog.h"
#import "MGPassthroughPersistentStoreCoordinator.h"
#import "MGPassthroughManagedObjectContext.h"
#import "MGMetadataModel.h"
#import "MGRuntimeException.h"


//
// Main Implementation
//
@implementation MGMetadataBackingStore  {
    NSPersistentStoreCoordinator * persistentStoreCoordinator;
    NSManagedObjectModel         * managedObjectModel;
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
    if (!persistentStoreCoordinator) {
        
        LogInfo(@"Creating metadata backing store...");

        BOOL            removeIncompatibleStore = YES;
        
        NSFileManager * fileManager      = [NSFileManager defaultManager];
        NSString      * storageDirectory = [self storageDirectory];
        NSString      * storePath        = [storageDirectory stringByAppendingPathComponent: @"connect.sqlite"];
        NSURL         * storeUrl         = [NSURL fileURLWithPath: storePath isDirectory: NO];
        
        NSError       * error = nil;
        //
        // Create the persistent store coordinator
        // so we can attache the persistent stores
        // to it.
        //
        persistentStoreCoordinator = [[MGPassthroughPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
        
        LogInfo(@"Attaching persistent store...");
        
        if ([fileManager fileExistsAtPath: storePath]) {
            
            NSDictionary * metadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType: NSSQLiteStoreType URL: storeUrl error: &error];
            
            if (![managedObjectModel isConfiguration: nil compatibleWithStoreMetadata: metadata]) {
                
                if (removeIncompatibleStore) {
                    
                    LogTrace(1, @"Removing incompatible persistent store at path %@", storePath);
                    
                    //
                    // If the existing persistentStore is not compatible with the structure
                    // provided, we need to delete it and recreate it.
                    //
                    if (![fileManager removeItemAtPath: storePath error: &error]) {
                        @throw [MGRuntimeException exceptionWithName: @"PersistentStore Creation Exception" reason: [NSString stringWithFormat: @"%@: Could not remove incompatible persistent store", [error localizedDescription]] userInfo: nil];
                    }
                    
                    LogTrace(1, @"Persistent store removed");
                } else {
                    @throw [MGRuntimeException exceptionWithName: @"PersistentStore Creation Exception" reason: @"The existing persistent store is not compatible with the managed object model" userInfo: nil];
                }
            }
        } 

        NSDictionary * options = nil;

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
        options =  @{NSPersistentStoreFileProtectionKey: NSFileProtectionComplete};

#endif
        NSPersistentStore * persistentStore = [persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType configuration: nil URL: storeUrl options: options error:&error];
        
        if (!persistentStore) {
            
            NSString * errorMessage = [NSString stringWithFormat: @"Failed to add PersistentStore"];
            
            @throw [MGRuntimeException exceptionWithName: errorMessage reason: [error localizedDescription] userInfo: [[NSDictionary alloc] initWithObjectsAndKeys: error, @"error", nil]];
        }
        
        LogTrace(1, @"Attached persistent store %@", storePath);
        
#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
        //
        // Check to make sure the protection key is what was specified in the database
        //
        NSDictionary * currentAttributes = [fileManager attributesOfItemAtPath: storePath error: nil];
        
        if ([currentAttributes objectForKey: NSFileProtectionKey] != NSFileProtectionComplete) {
            NSDictionary * fileAttributes = [[NSDictionary alloc] initWithObjectsAndKeys: NSFileProtectionComplete, NSFileProtectionKey, nil];
            
            [fileManager setAttributes: fileAttributes ofItemAtPath: storePath error: nil];
        }
#endif
        
        LogInfo(@"Metadata backing store created");
    }
    
    return persistentStoreCoordinator;
}

- (NSManagedObjectModel *) managedObjectModel {
    
    if (!managedObjectModel) {
        managedObjectModel = [MGMetadataModel managedObjectModel];
    }
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
        NSManagedObjectContext * editContext = [[MGPassthroughManagedObjectContext alloc] init];
        [editContext setPersistentStoreCoordinator: persistentStoreCoordinator];
        
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

#pragma mark - Private methods

- (NSString *) storageDirectory {
    
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingFormat: @"/connect"];
    
    NSError * error = nil;
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    //
    // Determine directory and create it if not there
    //
    if (![fileManager fileExistsAtPath: path]) {
        [fileManager  createDirectoryAtPath: path withIntermediateDirectories: YES attributes: nil error: &error];
    }

    return path;
}

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
