//
//  MGPersistentStoreCoordinator.m
//  Connect
//
//  Created by Tony Stone on 5/12/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGPersistentStoreCoordinator.h"
#import "MGModelMangler.h"
#import "MGPersistentStore.h"
#import "MGInMemoryPersistentStore.h"
#import "MGSQLitePersistentStore.h"

#import <ConnectCommon/ConnectCommon.h>

FOUNDATION_EXPORT double ConnectVersionNumber;

//
//  Private internal Objective-C interface.
//
@interface MGPersistentStoreCoordinator (Private)

    - (void) commonInitManagedObjectModel: (NSManagedObjectModel *) aModel connectConfigurationURL: (NSURL *) configurationURL;
    - (NSURL *) connectConfigurationURL: (NSString *) aFileName;
    - (void) loadConnectConfiguration;
    - (BOOL) checkDependentLibraries;

    + (void) registerPersistentStoreClass: (Class <MGPersistentStore>) aPersistentStoreClass;

@end

//
// Main instance configuration structure
// with default flag values.
//
typedef struct  {
    unsigned int logged:1;
    unsigned int synchronized:1;
    unsigned int connectManaged:1;
    unsigned int reserved:29;
} PersistentStoreCoordinatorFlags;

#define DEFAULT_LOGGED          NO
#define DEFAULT_SYNCHRONIZED    NO
#define DEFAULT_CONNECT_MANAGED NO
#define DEFAULT_CONFIG_FILE     @"config.connect"

static PersistentStoreCoordinatorFlags defaultFlags =
        {
                DEFAULT_LOGGED,
                DEFAULT_SYNCHRONIZED,
                DEFAULT_CONNECT_MANAGED,
                0
        };

//
// Main implementation
//
@implementation MGPersistentStoreCoordinator {
    PersistentStoreCoordinatorFlags flags;
}

    - (id) initWithManagedObjectModel:(NSManagedObjectModel *) aModel {

        // Note: must be done before initializing the super glass.
        [self commonInitManagedObjectModel: aModel connectConfigurationURL: [self connectConfigurationURL: DEFAULT_CONFIG_FILE]];

        return [super initWithManagedObjectModel: aModel];
    }

    - (id) initWithManagedObjectModel: (NSManagedObjectModel *) aModel connectConfigurationURL: (NSURL *) configurationURL {

        // Note: must be done before initializing the super glass.
        [self commonInitManagedObjectModel: aModel connectConfigurationURL: configurationURL];

        return [super initWithManagedObjectModel: aModel];
    }

    - (NSPersistentStore *) addPersistentStoreWithType:(NSString *)storeType configuration:(NSString *)configuration URL:(NSURL *)storeURL options:(NSDictionary *)options error:(NSError *__autoreleasing *)error {

        if (flags.connectManaged) {
            LogTrace(1, @"Attaching persistent store: %@", [storeURL path]);
            
            // Do whatever Connect has to do
        }
        return [super addPersistentStoreWithType: storeType configuration: configuration URL: storeURL options: options error: error];
    }

    - (BOOL) removePersistentStore:(NSPersistentStore *)store error:(NSError *__autoreleasing *)error {

        if (flags.connectManaged) {
            LogTrace(1, @"Removing persistent store: %@", [[store URL] path]);
            
            // Do whatever Connect has to do
        }
        return [super removePersistentStore: store error: error];
    }

@end


@implementation MGPersistentStoreCoordinator (Private)

    - (void) commonInitManagedObjectModel: (NSManagedObjectModel *) aModel connectConfigurationURL: (NSURL *)configurationURL  {
        LogInfo(@"Initializing instance...");

        //
        // Default the flags initially
        //
        flags = defaultFlags;

        if ([self checkDependentLibraries]) {

            if (configurationURL) {
                
                if ([[NSFileManager defaultManager] fileExistsAtPath: [configurationURL path]]) {
                    MGWADLApplication * configuration = [MGConfigurationReader connectConfigurationFromURL: configurationURL];
                    
                    if (configuration) {
                        LogTrace(1, @"Configuration: %@", configuration);
                        
                        //
                        // Process the model before giving it to the super class
                        //
                        [MGModelMangler configureModel:aModel forConnectConfiguration: configuration];
                        
                        flags.connectManaged = YES;
                    }

                } else {
                    LogWarning(@"Configuration file \"%@\" not found, %@ will not be managed.", configurationURL, NSStringFromClass([self class]));
                }
            } else {
                LogWarning(@"No connect configuration file supplied, %@ will not be managed.", NSStringFromClass([self class]));
            }
        }
    }

    - (NSURL *) connectConfigurationURL: (NSString *) aFileName {
        NSString * resource  = [aFileName stringByDeletingPathExtension];
        NSString * extension = [aFileName pathExtension];

        return [[NSBundle mainBundle] URLForResource: resource withExtension: extension];
    }

    - (void) loadConnectConfiguration {

    }

    - (BOOL) checkDependentLibraries {
        BOOL dependentsCompatible = YES;

        //
        // Make sure ConnectCommon has a compatible version of the library running.
        //
        if (ConnectCommonVersionNumber < ConnectVersionNumber) {
            LogError(@"The MGConnectCommon.framework version (%0.2f) is not capatible with MGConnect's version (%0.2f), shutting down...", ConnectCommonVersionNumber, ConnectVersionNumber);

            dependentsCompatible = NO;
        }

        return dependentsCompatible;
    }

    + (void) registerPersistentStoreClass: (Class <MGPersistentStore>) aPersistentStoreClass {
    
        [NSPersistentStoreCoordinator registerStoreClass: aPersistentStoreClass forStoreType: [aPersistentStoreClass storeType]];
    
        LogInfo(@"PersistentStoreType \"%@\" registered.", [aPersistentStoreClass storeType]);
    }

@end

//
// Constant values defined in public header.
//
NSString * const MGInMemoryStoreType  = @"MGInMemoryPersistentStore"; // [MGInMemoryPersistentStore storeType];
NSString * const MGSQLiteStoreType    = @"MGSQLitePersistentStore"; // [MGSQLitePersistentStore storeType];
