//
//  MGDataStoreManager.m
//  MGConnect
//
//  Created by Tony Stone on 3/29/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGDataStoreManager.h"
#import "MGConnect+EntitySettings.h"
#import "MGConnect+PrivateSettings.h"
#import "MGMetadataModel.h"
#import "MGBackingStore.h"
#import "MGTraceLog.h"
#import "MGActionQueue.h"
#import "MGEntityAction.h"
#import "MGEntityActionDefinition+Private.h"
#import "MGWebService.h"
#import "MGTransactionLogManager.h"
#import "MGLoggedManagedObjectContext.h"
#import "MGResourceReferenceDataMergeOperation.h"
#import "MGXPathV1ObjectMapper.h"
#import "MGConnect+PrivateSettings.h"

static MGDataMergeOperation * defaultDataMergeOperation;

/**
 Main implementation
 */
@implementation MGDataStoreManager {
    NSManagedObjectModel          * managedObjectModel;
    MGLoggedManagedObjectContext  * mainThreadManagedObjectContext;
    NSString                      * dataStoreName;
    NSString                      * dataStorePath;
    
    MGBackingStore                * dataCache;
    MGBackingStore                * metadata;
    MGTransactionLogManager       * transactionLogManager;
    
    CFMutableDictionaryRef actionQueuesByEntityPointer;
}

- (void) open: (NSDictionary *) options  {
    
    LogInfo(@"Opening data store \"%@\"...", dataStoreName);
#warning FIXME: I believe the options should be processed at this level so that global options like MGRemoveIncompatibleStoreOption & NSPersistentStoreFileProtectionKey can be set for the meta store
    
    metadata              = [[MGBackingStore alloc] initWithType: MGBackingStoreTypeMetadata  managedObjectModel: [MGMetadataModel managedObjectModel] storagePath: [self dataStorePath] options: @{MGRemoveIncompatibleStoreOption: @YES}];
    dataCache             = [[MGBackingStore alloc] initWithType: MGBackingStoreTypeDataCache managedObjectModel: managedObjectModel                   storagePath: [self dataStorePath] options: options];
    
    transactionLogManager = [[MGTransactionLogManager alloc] initWithMetadataStore: metadata];
    
    //
    // Force the stack to load by getting the mainThreadManagedObjectContext on the main thread
    //
    (void) [self performSelectorOnMainThread: @selector(mainThreadManagedObjectContext) withObject: nil waitUntilDone: YES];
    
    LogInfo(@"Data store \"%@\" opened", dataStoreName);
}

- (void) close {
    LogInfo(@"Closing data store \"%@\"...", dataStoreName);
    
    [metadata  reset];
    [dataCache reset];
    
    transactionLogManager   = nil;
    metadata                = nil;
    dataCache               = nil;

    LogInfo(@"Data store \"%@\" closed", dataStoreName);
}

- (NSManagedObjectContext *) mainThreadManagedObjectContext {
    
    if (!mainThreadManagedObjectContext) {
        NSPersistentStoreCoordinator *coordinator = [dataCache persistentStoreCoordinator];
        if (coordinator != nil) {
            mainThreadManagedObjectContext = [[MGLoggedManagedObjectContext alloc] initWithDataStoreManager: self notificationSelector: @selector(handleContextDidSaveNotification:) transactionLogManager: transactionLogManager];
            [mainThreadManagedObjectContext setPersistentStoreCoordinator: coordinator];
        }
    }
    return mainThreadManagedObjectContext;
}

- (NSManagedObjectContext *)  editManagedObjectContext {
    NSManagedObjectContext * editManagedObjectContext = nil;
    
    NSPersistentStoreCoordinator *coordinator = [dataCache persistentStoreCoordinator];
    if (coordinator != nil) {
        editManagedObjectContext = [[MGLoggedManagedObjectContext alloc] initWithDataStoreManager: self notificationSelector: @selector(handleContextDidSaveNotification:) transactionLogManager: transactionLogManager];
        [editManagedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return editManagedObjectContext;
}

#pragma mark - Context Management

// NOTE: From the documentation "In a multithreaded application, notifications
//       are always delivered in the thread in which the notification was posted,
//       which may not be the same thread in which an observer registered itself."
//
//      This means that care must be taken in this method to ensure we respect
//      thread and context rules.
//
- (void) handleContextDidSaveNotification:(NSNotification *) notification {
    
    // Dispatch the merging of changes to the main thread
    
    void (^mergeChanges)(void) = ^{
        
        @autoreleasepool {
            
            @try {
                NSManagedObjectContext * notificationContext = [notification object];
                
                if (![notificationContext isEqual: mainThreadManagedObjectContext]) {
                    
                    [[mainThreadManagedObjectContext undoManager] disableUndoRegistration];
                    
                    // Merge the changes into our main context
                    [mainThreadManagedObjectContext mergeChangesFromContextDidSaveNotification: notification];
                    
                    NSError * error = nil;
                    
                    if (![mainThreadManagedObjectContext save: &error logChanges: NO]) {
                        @throw [MGRuntimeException exceptionWithName: @"Merge Exception" reason: [error localizedDescription] userInfo: @{@"error": error}];
                    }
                    
                    [[mainThreadManagedObjectContext undoManager] enableUndoRegistration];
                }
            }
            @catch (NSException *exception) {
                LogError(@"%@ : %@", [exception name], [exception reason]);
                
                // Report this error through the error system
            }
        }
    };
    
    if ([NSThread isMainThread]) {
        mergeChanges();
    } else {
        dispatch_sync(dispatch_get_main_queue(), mergeChanges);
    }
}

- (void) start {
    
    LogInfo(@"Starting...");
    
    LogInfo(@"Started");
}

- (void) stop {
    LogInfo(@"Stopping...");
    
    LogInfo(@"Stopped");
}

- (void) setOffline {
    
}

- (void) setOnline {
    
}

- (void) executeAction: (MGEntityAction *) anAction waitUntilDone: (BOOL) wait {
    
    for (MGEntityAction * dependentAction in [anAction dependencies]) {
        //
        // We don't wait here because these are children of
        // the parent, no need to wait.
        //
        [self executeAction: dependentAction waitUntilDone: NO];
    }
    
    MGActionQueue * entityQueue = [self queueForEntity: [anAction entity]];

    [entityQueue addAction: anAction waitUntilDone: wait];
}

#pragma mark - Private Methods


- (MGActionQueue *) queueForEntity: (NSEntityDescription *) anEntity {
    return CFDictionaryGetValue(actionQueuesByEntityPointer, (__bridge const void *) anEntity);
}

- (NSString *) dataStorePath {
    
    if (!dataStorePath) {
        NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        path = [path stringByAppendingFormat: @"/datastore/%@", [dataStoreName lowercaseString]];
        
        NSError * error = nil;
        
        NSFileManager * fileManager = [NSFileManager defaultManager];
        
        //
        // Determine directory and create it if not there
        //
        if (![fileManager fileExistsAtPath: path]) {
            [fileManager  createDirectoryAtPath: path withIntermediateDirectories: YES attributes: nil error: &error];
        }
        dataStorePath = path;
    }
    return dataStorePath;
}

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end

@implementation MGDataStoreManager (Initialization)

+ (void) initialize {
    
    if (self == [MGDataStoreManager class]) {
        defaultDataMergeOperation = [[MGResourceReferenceDataMergeOperation alloc] init];
    }
}

- (id) initWithName: (NSString *) aDataStoreName managedObjectModel: (NSManagedObjectModel *) aManagedObjectModel {
    
    if ((self = [super init])) {
        
        LogInfo(@"Initializing...");
        
        managedObjectModel = aManagedObjectModel;
        dataStoreName      = aDataStoreName;
        
        actionQueuesByEntityPointer = CFDictionaryCreateMutable(NULL, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
        for (NSEntityDescription * anEntity in [aManagedObjectModel entities]) {
            
            MGEntityActionDefinition * actionDefinition = [anEntity entityActionDefinition];
            if (!actionDefinition) {
                //
                // Create a class name by removing the MG from MGEntityActionDefinition
                // and appending that to the entity name.
                //
                //  Example:
                //
                //     Entity Name: Cloud
                //
                //     Definition Name: CloudEntityActionDeifinition
                //
                NSString * actionDefinitionName = [[anEntity name] stringByAppendingString: [NSStringFromClass([MGEntityActionDefinition class]) substringFromIndex: 2]];
                
                //
                // See if the class exists
                //
                Class actionDefinitionClass  = NSClassFromString(actionDefinitionName);
                
                if (actionDefinitionClass && [actionDefinitionClass isSubclassOfClass: [MGEntityActionDefinition class]]) {
                    actionDefinition = [[actionDefinitionClass alloc] init];
                    
                    // Set this one on the class
                    [anEntity setEntityActionDefinition: actionDefinition];
                }
            }
            
            //
            // OK, at this point we've determined that we need to manage
            // this entity so we create a queue for it.
            //
            if (!actionDefinition) {
                [anEntity setManaged: NO];
            } else {
                [anEntity setManaged: YES];
                
                //
                // Create the action queue for this endity
                //
                LogTrace(1, @"Creating action queue for entity \"%@\"", [anEntity name]);
                
                MGActionQueue * aQueue = [[MGActionQueue alloc] initWithName: [anEntity name] mode: MGActionQueueSerial];
                
                CFDictionaryAddValue(actionQueuesByEntityPointer, CFBridgingRetain(anEntity), CFBridgingRetain(aQueue));
                
                //
                // Create the entitys object mapper instance
                //
                LogTrace(1, @"Creating ObjectMapper for entity \"%@\"", [anEntity name]);
                
                Class enityClass = NSClassFromString([anEntity managedObjectClassName]);
                
                id (^objectAllocationBlock)(void) = ^{
                    return [[NSManagedObject alloc] initWithEntity: anEntity insertIntoManagedObjectContext: nil];
                };

                NSObject <MGObjectMapper> * objectMapper = [[MGXPathV1ObjectMapper alloc] initWithObjectClass: enityClass objectAllocationBlock: objectAllocationBlock objectMapping: [actionDefinition mapping] objectRoot: nil];
                
                [anEntity setObjectMapper: objectMapper];
                
                //
                // Now create the web services
                //
                LogTrace(1, @"Creating web services for entity \"%@\"", [anEntity name]);
                
                MGWSDLDescription * wsdlDescription = [actionDefinition wsdl: [anEntity name]];
                
                NSArray * webServices = [MGWebService webServicesForWSDLDescription: wsdlDescription];
                if ([webServices count] > 0) {
                    //
                    // NOTE: Due to the way the MGEntityActionDefinition works, only one
                    //       web service is produced.  The generator though is designed to
                    //       produce as many web services as defined services in the definition
                    //
                    MGWebService * webService = [webServices lastObject];
                    
                    [anEntity setWebService: webService];
                }
            }
        }
        
        LogInfo(@"Initialized");
    }
    return self;
}

@end


