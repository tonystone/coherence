/**
 *   CCCache.m
 *
 *   Copyright 2015 The Climate Corporation
 *   Copyright 2015 Tony Stone
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *
 *   Created by Tony Stone on 5/15/15.
 */
#import "CCCache.h"
#import "CCPersistentStoreCoordinator.h"
#import "CCManagedObjectContext.h"

#import "CCAssert.h"
#import "NSManagedObjectModel+UniqueIdentity.h"
#import <TraceLog/TraceLog.h>

@interface CCCache (private)
    - (void) addPersistentStoreForConfiguration: (NSString *) configurationName  storeType: (NSString *) storeType storePath: (NSString *) storePath;
@end

@implementation CCCache {
        NSManagedObjectModel         * _managedObjectModel;
        CCPersistentStoreCoordinator * _persistentStoreCoordinator;

        CCManagedObjectContext       * _mainThreadContext;
    }

    - (instancetype) initWithManagedObjectModel:(NSManagedObjectModel *) aModel {

        NSParameterAssert(aModel != nil);

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
            _persistentStoreCoordinator = [[CCPersistentStoreCoordinator alloc] initWithManagedObjectModel: _managedObjectModel];

            [self addPersistentStoreForConfiguration: nil storeType: NSSQLiteStoreType storePath: storePath];

            //
            // We don't know if we're going to be created
            // on a background thread or not so we're
            // protecting the creation of the _mainThreadContext
            //
            [self performSelectorOnMainThread: @selector(createMainThreadContext) withObject:nil waitUntilDone: YES];

            // Start up the system
            [self start];

            LogInfo(@"'%@' instance initialized.", NSStringFromClass([self class]));
        }

        return self;
    }

    - (void) createMainThreadContext {
        AssertIsMainThread();

        LogInfo(@"Creating main thread context...");

        _mainThreadContext = [[CCManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
        [_mainThreadContext setPersistentStoreCoordinator: _persistentStoreCoordinator];

        LogInfo(@"Main thread context created.");
    }

    - (void) start {
        LogInfo(@"Starting...");

        LogInfo(@"Started.");
    }

    - (void) stop {
        LogInfo(@"Stopping...");

        LogInfo(@"Stopped.");
    }

    - (NSManagedObjectContext *) mainThreadContext {
        AssertIsMainThread();

        return _mainThreadContext;
    }

    - (NSManagedObjectContext *) editContext {
        LogInfo(@"Creating edit context...");
        
        NSManagedObjectContext * context = [[CCManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType parent: _mainThreadContext];
        [context setPersistentStoreCoordinator: _persistentStoreCoordinator];
        
        LogInfo(@"Edit context created.");
        
        return context;
    }

    - (void) clearAllData {

        @autoreleasepool {
            // We want callbacks here but we don't want any other behavior to kick off
            NSManagedObjectContext * editContext = [[NSManagedObjectContext alloc] init];
            [editContext setPersistentStoreCoordinator: _persistentStoreCoordinator];

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


@implementation CCCache (private)

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
