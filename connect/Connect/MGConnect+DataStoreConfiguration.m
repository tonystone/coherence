//
//  MGConnect+DataStoreConfiguration.m
//  MGConnect
//
//  Created by Tony Stone on 3/28/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnect+DataStoreConfiguration.h"
#import "MGConnect+Private.h"
#import "MGDataStoreManager.h"
#import "MGTraceLog.h"
#import "MGAssert.h"

@implementation MGConnect (DataStoreConfiguration)

- (void) registerDataStore: (NSString *) dataStoreName managedObjectModel:(NSManagedObjectModel *) aManagedObjectModel {
  
    NSParameterAssert(dataStoreName);
    NSParameterAssert(aManagedObjectModel);
    
    //
    // NOTE: Currently, this method can be called on any thread so no ASSERT protecting is needed.
    //
    LogInfo(@"Registering data store \"%@\" for model <%@: %p>...", dataStoreName, [aManagedObjectModel class], aManagedObjectModel);
    
    if (CFDictionaryContainsKey(((_ICS *)_ics)->dataStoreManagersByName, (__bridge const void *)(dataStoreName))) {
        
        @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [NSString stringWithFormat: @"Data store model <%@: %p> already registered. It can not be registered again.", [aManagedObjectModel class], aManagedObjectModel] userInfo: nil];
    }
    if (CFDictionaryContainsKey(((_ICS *)_ics)->dataStoreManagersByModelPointer, (__bridge const void *)(aManagedObjectModel))) {
        
        @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [NSString stringWithFormat: @"Data store \"%@\" already registered. It can not be registered again.", dataStoreName] userInfo: nil];
    }

    [self initializeSettingsForManagedObjectModel: aManagedObjectModel];
    
    MGDataStoreManager * dataStoreManager = [[MGDataStoreManager alloc] initWithName: dataStoreName managedObjectModel: aManagedObjectModel];
        
    CFDictionaryAddValue(((_ICS *)_ics)->dataStoreManagersByName,         CFBridgingRetain(dataStoreName),       CFBridgingRetain(dataStoreManager));
    CFDictionaryAddValue(((_ICS *)_ics)->dataStoreManagersByModelPointer, CFBridgingRetain(aManagedObjectModel), CFBridgingRetain(dataStoreManager));

    //
    // If we're started, start the new DataStore as well
    //
    if (((_ICS *)_ics)->active) {
        [dataStoreManager start];
        
        if (((_ICS *)_ics)->online) {
            [dataStoreManager setOnline];
        }
    }
    
    LogInfo(@"Data store \"%@\" registered", dataStoreName);
}

- (void) openDataStore: (NSString *) dataStoreName options: (NSDictionary *) options {

    NSParameterAssert(dataStoreName);
    
    LogInfo(@"Opening Data Store \"%@\"...", dataStoreName);
    
    MGDataStoreManager * dataStoreManager = (MGDataStoreManager *) CFDictionaryGetValue(((_ICS *)_ics)->dataStoreManagersByName, (__bridge const void *) dataStoreName);
    
    if (!dataStoreManager) {
        @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [NSString stringWithFormat: @"Data store \"%@\" not registered. It must be registered before opening it.", dataStoreName] userInfo: nil];
    }
    
    [dataStoreManager open: options];
        
    LogInfo(@"Data Store \"%@\" opened", dataStoreName);
}

- (void) closeDataStore: (NSString *) dataStoreName {

    NSParameterAssert(dataStoreName);
    
    LogInfo(@"Closing Data Store \"%@\"...", dataStoreName);
    
    MGDataStoreManager * dataStoreManager = CFDictionaryGetValue(((_ICS *)_ics)->dataStoreManagersByName, (__bridge const void *) dataStoreName);
    
    if (!dataStoreManager) {
        @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [NSString stringWithFormat: @"Data store \"%@\" not registered. It must be registered before opening/closing it.", dataStoreName] userInfo: nil];
    }
    
    [dataStoreManager close];
        
    LogInfo(@"Data Store \"%@\" closed", dataStoreName);
}

- (NSManagedObjectContext *) mainThreadManagedObjectContextForDataStore: (NSString *) dataStoreName {
    
    MGAssertIsMainThread();
    NSParameterAssert(dataStoreName);
    NSAssert(CFDictionaryContainsKey(((_ICS *)_ics)->dataStoreManagersByName, (__bridge const void *) dataStoreName), @"The default DataStore is not open, you must open the DataStore before getting a managedObjectContext");

    MGDataStoreManager * dataStoreManager = CFDictionaryGetValue(((_ICS *)_ics)->dataStoreManagersByName, (__bridge const void *)(dataStoreName));
    
    return [dataStoreManager mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *) editManagedObjectContextForDataStore: (NSString *) dataStoreName {
    
    NSParameterAssert(dataStoreName);
    NSAssert(CFDictionaryContainsKey(((_ICS *)_ics)->dataStoreManagersByName, (__bridge const void *) dataStoreName), @"The default DataStore is not open, you must open the DataStore before getting a managedObjectContext");
    
    MGDataStoreManager * dataStoreManager = CFDictionaryGetValue(((_ICS *)_ics)->dataStoreManagersByName, (__bridge const void *)(dataStoreName));
    
    return [dataStoreManager mainThreadManagedObjectContext];
}

#pragma mark - Internal Private Methods

- (void) initializeSettingsForManagedObjectModel: (NSManagedObjectModel *) aManagedObjectModel {
    
    //
    // NOTE: Currently, this method can be called on any thread so no ASSERT protecting is needed.
    //
    LogInfo(@"Initializing model <%@: %p>...", [aManagedObjectModel class], aManagedObjectModel);
    
    if (!CFDictionaryContainsKey(((_ICS *)_ics)->settingsByModelPointer, (__bridge const void *)(aManagedObjectModel))) {
        
        MGSettings * settings =  [[MGSettings alloc] init];
        
        CFDictionaryAddValue(((_ICS *)_ics)->settingsByModelPointer, CFBridgingRetain(aManagedObjectModel),  CFBridgingRetain(settings));
        
        [settings loadFromManagedObjectModel: aManagedObjectModel];
        
        LogInfo(@"Model <%@: %p> initialized", [aManagedObjectModel class], aManagedObjectModel);
    } else {
        LogWarning(@"Model <%@: %p> already initialized. It can not be initialize again.", [aManagedObjectModel class], aManagedObjectModel);
    }
}

@end
