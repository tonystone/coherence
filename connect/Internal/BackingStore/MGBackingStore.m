//
//  MGBackingStore.m
//  CloudScope
//
//  Created by Tony Stone on 2/21/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import "MGBackingStore.h"
#import <CoreData/CoreData.h>
#import "MGRuntimeException.h"
#import "MGConnect+Private.h"
@import TraceLog;

MGBackingStoreType const MGBackingStoreTypeMetadata    = @"metadata";
MGBackingStoreType const MGBackingStoreTypeDataCache   = @"datacache";

NSString * const MGRemoveIncompatibleStoreOption                = @"MGRemoveIncompatibleStoreOption";
NSString * const MGPersistentStoreTypeStoreKey                  = @"MGPersistentStoreTypeStoreKey";
NSString * const MGPersistentStoreGroupIDStoreKey               = @"MGPersistentStoreGroupIDStoreKey";
NSString * const MGPersistentStoreInstanceIDStoreKey            = @"MGPersistentStoreInstanceIDStoreKey";
NSString * const MGPersistentStoreDataInitializerClassStoreKey  = @"MGPersistentStoreDataInitializerClassStoreKey";

@implementation MGBackingStore {
    MGBackingStoreType    type;
    NSMutableDictionary * backingStoreOptionsByConfiguration;
    NSMutableDictionary * persistentStoreOptionsByConfiguration;
    
    dispatch_queue_t    serialAccessQueue;
    
    NSString            * storagePath;
}

- (id) initWithType: (MGBackingStoreType) aStoreType managedObjectModel: (NSManagedObjectModel *) aManagedObjectModel storagePath: (NSString *) aStoragePath options: (NSDictionary *) options {
    
    NSParameterAssert(aStoreType != nil);
    NSParameterAssert(aManagedObjectModel);
    NSParameterAssert(aStoragePath);
    
    if ((self = [super init])) {
        type                = aStoreType;
        managedObjectModel  = aManagedObjectModel;
        storagePath         = aStoragePath;
        
        [self processBackingStoreOptions: options];
        
        NSString * synchronizationQueueName = [NSString stringWithFormat: @"com.mobilegridinc.%@.%p.serialAccessQueue", type, self];
        
        serialAccessQueue = dispatch_queue_create([synchronizationQueueName UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}


- (void) processBackingStoreOptions: (NSDictionary *) backingStoreOptions {
    
    NSMutableDictionary * globalBackingStoreOptions     = [[NSMutableDictionary alloc] initWithCapacity:[backingStoreOptions count]];
    NSMutableDictionary * globalPersistentStoreOptions  = [[NSMutableDictionary alloc] initWithCapacity:[backingStoreOptions count]];
    NSMutableDictionary * configurations                = [[NSMutableDictionary alloc] initWithCapacity: 3];
    
    //
    // Collect the global options and a list of all the configuration names
    //
    for (NSString * key in [backingStoreOptions allKeys]) {
        
        if (key == MGRemoveIncompatibleStoreOption                  ||
            key == MGPersistentStoreTypeStoreKey                    ||
            key == MGPersistentStoreGroupIDStoreKey                 ||
            key == MGPersistentStoreInstanceIDStoreKey              ||
            key == MGPersistentStoreDataInitializerClassStoreKey)
        {
            [globalBackingStoreOptions setObject: [backingStoreOptions objectForKey: key] forKey: key];         
        }
        else
        if (key == NSReadOnlyPersistentStoreOption           ||
            key == NSPersistentStoreTimeoutOption            ||
            key == NSSQLitePragmasOption                     ||
            key == NSSQLiteAnalyzeOption                     ||
            key == NSSQLiteManualVacuumOption                ||
            key == NSPersistentStoreUbiquitousContentNameKey ||
            key == NSPersistentStoreUbiquitousContentURLKey  ||
            key == NSPersistentStoreFileProtectionKey)
        {
            [globalPersistentStoreOptions setObject: [backingStoreOptions objectForKey: key] forKey: key];
        } else {
            
            //
            // If the key is not one of the above,
            // we assume it is a configuration name.
            //
            
            id configurationOptions = [backingStoreOptions objectForKey: key];
            
            if (![configurationOptions isKindOfClass: [NSDictionary class]]) {
                NSString * exceptionName   = @"Runtime Exception";
                NSString * exceptionReason = [NSString stringWithFormat: @"Your options dictionary is invalid, configuration name \"%@\" must have value of type NSDictionary", key];
                
                LogError(@"%@ : %@", exceptionName, exceptionReason);
                
                @throw [MGRuntimeException exceptionWithName: exceptionName reason: exceptionReason userInfo: nil];
            }
            
            [configurations setObject: configurationOptions forKey: key];
        }
    }
    //
    // If we end up with no configurations, add the default configuration
    // because we must have at least one.
    //
    if ([configurations count] == 0) {
        [configurations setObject: [[NSDictionary alloc] init] forKey: kDefaultConfiguration];
    }
    
    backingStoreOptionsByConfiguration    = [[NSMutableDictionary alloc] init];    
    persistentStoreOptionsByConfiguration = [[NSMutableDictionary alloc] init];

    //
    // Now build the configuration options needed for each configuration
    //
    for (NSString * configurationName in configurations) {
        
        NSDictionary * configurationOptions = [configurations objectForKey: configurationName];
        
        NSMutableDictionary * mergedBackingStoreOptions    = [[NSMutableDictionary alloc] init];
        NSMutableDictionary * mergedPersistentStoreOptions = [[NSMutableDictionary alloc] init];
        
        for (NSString * key in [configurationOptions allKeys]) {
            
            if (key == MGRemoveIncompatibleStoreOption                  ||
                key == MGPersistentStoreTypeStoreKey                    ||
                key == MGPersistentStoreGroupIDStoreKey                 ||
                key == MGPersistentStoreInstanceIDStoreKey              ||
                key == MGPersistentStoreDataInitializerClassStoreKey)
            {
                [mergedBackingStoreOptions setObject: [configurationOptions objectForKey: key] forKey: key];
            }
            else
            if (key == NSReadOnlyPersistentStoreOption           ||
                key == NSPersistentStoreTimeoutOption            ||
                key == NSSQLitePragmasOption                     ||
                key == NSSQLiteAnalyzeOption                     ||
                key == NSSQLiteManualVacuumOption                ||
                key == NSPersistentStoreUbiquitousContentNameKey ||
                key == NSPersistentStoreUbiquitousContentURLKey  ||
                key == NSPersistentStoreFileProtectionKey)
            {
                [mergedPersistentStoreOptions setObject: [configurationOptions objectForKey: key] forKey: key];
            } else {
                LogWarning(@"Unsupported option in options dictionary, discarding option \"%@\"", key);
            }
        }
        
        // Now, merge the global options into the options for the configuration
        for (NSString * key in [globalBackingStoreOptions allKeys]) {
            if (![mergedBackingStoreOptions objectForKey: key]) {
                [mergedBackingStoreOptions setObject: [globalBackingStoreOptions objectForKey: key] forKey: key];             
            }
        }
        for (NSString * key in [globalPersistentStoreOptions allKeys]) {
            if (![mergedPersistentStoreOptions objectForKey: key]) {
                [mergedPersistentStoreOptions setObject: [globalPersistentStoreOptions objectForKey: key] forKey: key];
            }
        }
        
        //
        // Now we need to process the rquired keys and values and assign defaults if missing
        //
        [self assignDefaultOptionsIfAbsent: configurationName backingStoreOptions: mergedBackingStoreOptions persistentStoreOptions: mergedPersistentStoreOptions];
        
        //
        // Finally, add the configuration and options to our instance variables to be used later
        //
        [backingStoreOptionsByConfiguration    setObject: mergedBackingStoreOptions    forKey: configurationName];
        [persistentStoreOptionsByConfiguration setObject: mergedPersistentStoreOptions forKey: configurationName];
    }
    // Finally, we are done
}

- (void) assignDefaultOptionsIfAbsent: (NSString *) configurationName backingStoreOptions: (NSMutableDictionary *) backingStoreOptions persistentStoreOptions: (NSMutableDictionary *) persistentStoreOptions {
    
    //
    // First the backing store options
    //
    if (![backingStoreOptions objectForKey: MGRemoveIncompatibleStoreOption]) {
        [backingStoreOptions setValue: @NO forKey: MGRemoveIncompatibleStoreOption];
    }
    
    if (![backingStoreOptions objectForKey: MGPersistentStoreTypeStoreKey]) {
         [backingStoreOptions setValue: NSSQLiteStoreType forKey: MGPersistentStoreTypeStoreKey];
    }

    //
    // Now get the persistent store options
    //
    if (![persistentStoreOptions objectForKey: NSReadOnlyPersistentStoreOption]) {
        [persistentStoreOptions setObject: @NO forKey: NSReadOnlyPersistentStoreOption];
    }
    
}

- (void) handleContextDidSaveNotification: (NSNotification *) notification {
    ; // Default does nothing
}

- (void) addPersistentStoreForConfiguration: (NSString *) configurationName backingStoreOptions: (NSDictionary *) backingStoreOptions persistentStoreOptions: (NSDictionary *) persistentStoreOptions {
    
    LogInfo(@"Attaching persistent store for configuration %@", configurationName);
    LogTrace(2, @"BackingStore options: \n%@", backingStoreOptions);
    LogTrace(2, @"PersistentStore options: \n%@", persistentStoreOptions);
    
    NSFileManager * fileManager     = [NSFileManager defaultManager];
    NSString      * storeType       = [backingStoreOptions objectForKey: MGPersistentStoreTypeStoreKey];
    
    NSString      * storeGroup      = [backingStoreOptions objectForKey: MGPersistentStoreGroupIDStoreKey];
    NSString      * storeInstance   = [backingStoreOptions objectForKey: MGPersistentStoreInstanceIDStoreKey];
    NSString      * storeName       = [NSString stringWithFormat: @"%@%@%@",
                                       storeGroup        ? storeGroup : type,
                                       configurationName ? [@"-" stringByAppendingString: configurationName] : @"",
                                       storeInstance     ? [@"-" stringByAppendingString: storeInstance]     : @""];
    
    NSString      * storePath       = [storagePath stringByAppendingFormat: @"/%@.%@", storeName, [self extensionForStoreType: storeType]];
    NSURL         * storeUrl        = [NSURL fileURLWithPath: storePath];

    BOOL            removeIncompatibleStore = [[backingStoreOptions objectForKey: MGRemoveIncompatibleStoreOption] boolValue];
    
    NSString      * fileProtectionKey    = [persistentStoreOptions  objectForKey: NSFileProtectionKey];
    BOOL            openReadOnly         = [[persistentStoreOptions objectForKey: NSReadOnlyPersistentStoreOption] boolValue];
    NSString      * initializerClassName = [backingStoreOptions objectForKey: MGPersistentStoreDataInitializerClassStoreKey];
    BOOL            initializeData       = NO;

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
                    @throw [MGRuntimeException exceptionWithName: @"PersistentStore Creation Exception" reason: [NSString stringWithFormat: @"%@: Could not remove incompatible persistent store", [error localizedDescription]] userInfo: nil];
                }
                
                LogTrace(1, @"Persistent store removed");
                
                //
                // We've delete the old store so we'll need to initialize the data in it.
                //
                initializeData = YES;
            } else {
                @throw [MGRuntimeException exceptionWithName: @"PersistentStore Creation Exception" reason: @"The existing persistent store is not compatible with the managed object model" userInfo: nil];
            }
        }
    } else {
        //
        // No previous store found so this is a creation which means we'll
        // need to initialize the data.
        //
        initializeData = YES;
    }

    persistentStore = [persistentStoreCoordinator addPersistentStoreWithType: storeType configuration: configurationName URL: storeUrl options: persistentStoreOptions error:&error];
    
    if (!persistentStore) {
        
        NSString * errorMessage = [NSString stringWithFormat: @"Failed to add PersistentStore <%@>", configurationName];
        
        @throw [NSException exceptionWithName: errorMessage reason: [error localizedDescription] userInfo: [[NSDictionary alloc] initWithObjectsAndKeys: error, @"error", nil]];
    }
    
    LogTrace(1, @"Attached persistent store %@", storePath);
    
#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
    //
    // Check to make sure the protection key is what was specified in the database
    //
    NSDictionary * currentAttributes = [fileManager attributesOfItemAtPath: storePath error: nil];
    
    if ([currentAttributes objectForKey: NSFileProtectionKey] != fileProtectionKey) {
        NSDictionary * fileAttributes = [[NSDictionary alloc] initWithObjectsAndKeys: fileProtectionKey, NSFileProtectionKey, nil];
        
        [fileManager setAttributes: fileAttributes ofItemAtPath: storePath error: nil];
    }
#endif
    
    // Call the initializer if one is present and needed
    if (initializeData && initializerClassName) {
        Class initializerClass = NSClassFromString(initializerClassName);
        
        if (!initializerClass) {
            @throw [MGRuntimeException exceptionWithName: @"PersistentStore Creation Exception" reason: @"The MGPersistentStoreDataInitializerClassStoreKey class specified does not exist, could not initialize the PersistentStore" userInfo: nil];  
        }
        
        //
        // Note: if the store was opened readonly, we need to
        // turn that off before adding any data
        //
        if (openReadOnly) {
            [persistentStore setReadOnly: NO];
        }
    
        [self initializeDataUsingClass: initializerClass persistentStoreCoodinator: persistentStoreCoordinator];
        
        if (openReadOnly) {
            [persistentStore setReadOnly: YES];
        }
    }
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
    if (!persistentStoreCoordinator) {
        
        LogInfo(@"Creating persistent store coordinator...");
        
        //
        // Create the persistent store coordinator
        // so we can attache the persistent stores
        // to it.
        //
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
        
        //
        // Loop through the configurations declared in the
        // persistentStoreConfigurations dictionary
        //
        for (NSString * configurationName in [backingStoreOptionsByConfiguration allKeys]) {
            
            if (![configurationName isEqualToString: kDefaultConfiguration] && ![[[self managedObjectModel] configurations] containsObject: configurationName]) {
                @throw [MGRuntimeException exceptionWithName: @"Invalid Configuration Name" reason: [NSString stringWithFormat: @"You specified configuration \"%@\" in your options but the NSManagedObjectModel does not contain this configuration", configurationName] userInfo: nil];
            }
            
            [self addPersistentStoreForConfiguration: [configurationName isEqualToString: kDefaultConfiguration] ? nil : configurationName backingStoreOptions: [backingStoreOptionsByConfiguration objectForKey: configurationName] persistentStoreOptions: [persistentStoreOptionsByConfiguration objectForKey: configurationName]];
        }
        
        LogInfo(@"Persistent store coordinator created");
    }
    
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

- (void)  initializeDataUsingClass: (Class) initializerClass persistentStoreCoodinator: (NSPersistentStoreCoordinator *) aPersistentStoreCoordinator {
    // Call the initializer if one is present and needed
    if (initializerClass && [initializerClass respondsToSelector: @selector(loadDataInContext:)]) {
        NSManagedObjectContext * loadContext = [[NSManagedObjectContext alloc] init];
        [loadContext setPersistentStoreCoordinator: aPersistentStoreCoordinator];
        
        [initializerClass performSelector: @selector(loadDataInContext:) withObject: loadContext];
    }
}

#pragma mark - Internal Package level methods

- (NSString *) extensionForStoreType: (NSString *) storeType {
    
    if ([storeType isEqualToString: NSSQLiteStoreType]) {
        return @"sqlite";
    } else if ([storeType isEqualToString: NSBinaryStoreType]) {
        return @"bin";
    } else if ([storeType isEqualToString: NSInMemoryStoreType]) {
        return @"mem";
    }
    return @"custom";
}


@end
