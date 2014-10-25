//
//  MGConnect.m
//  MGConnect
//
//  Created by Tony Stone on 3/26/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnect+Private.h"
#import "MGConnect+DataStoreConfiguration.h"
#import "MGNetworkMonitor.h"
#import "MGTraceLog.h"
#import <objc/runtime.h>
#import <CoreFoundation/CoreFoundation.h>
#import "MGDataStoreManager.h"
#import "MGAssert.h"

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
#import <UIKIt/UIKit.h>
#endif

// TESTING ONLY, DELETE these
#import "MGEntityActionDefinition+Private.h"
#import "MGWebService.h"

//
// Single instance of this MGConnect
//
MGConnect * __mgRMSharedManager;

//
// Main Implementation
//
@implementation MGConnect

#pragma mark - Public Methods

+ (MGConnect *)sharedManager {
    return __mgRMSharedManager;
}

+ (void) initializeWithManagedObjectModel: (NSManagedObjectModel *) aManagedObjectModel {
    
    MGAssertIsMainThread();
    NSParameterAssert(aManagedObjectModel);
    
    [[self sharedManager] registerDataStore: MGDefaultDataStoreName managedObjectModel: aManagedObjectModel];
    [[self sharedManager]     openDataStore: MGDefaultDataStoreName options: nil];
}

- (NSManagedObjectContext *) mainThreadManagedObjectContext {
    
    MGAssertIsMainThread();
    
    return [self mainThreadManagedObjectContextForDataStore: MGDefaultDataStoreName];
}

- (NSManagedObjectContext *) editManagedObjectContext {

    return [self mainThreadManagedObjectContextForDataStore: MGDefaultDataStoreName];
}

#pragma mark - Class Initialization & Cleanup

//
// Initialize once in main thread
//
+ (void) initialize {
    
    if (self == [MGConnect class]) {
        
        LogInfo(@"Initializing...");

        //
        // Force the settings system to load
        //
        (void) [MGSettings version];
        
        //
        // Once everthing is initialized, we can create the instance of MGResoureManager
        //
        __mgRMSharedManager = [[self alloc] init];
        
        LogInfo(@"Initialized");
    }
}
#pragma mark - Instance Initialization & Cleanup
//
// Default init to get MGConnect into a valid state
//
- (id) init {
    
    if ((self = [super init])) {
        //
        // Create the internal structures
        //
        _ics =  (_ICS *) malloc(sizeof(_ICS));

        ((_ICS *)_ics)->settingsByModelPointer          = CFDictionaryCreateMutable(NULL, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        ((_ICS *)_ics)->dataStoreManagersByModelPointer = CFDictionaryCreateMutable(NULL, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        ((_ICS *)_ics)->dataStoreManagersByName         = CFDictionaryCreateMutable(NULL, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
        ((_ICS *)_ics)->active = NO;
        ((_ICS *)_ics)->online = NO;
        
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleProtectedDataWillBecomeUnavailable:)          name: UIApplicationProtectedDataWillBecomeUnavailable object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleProtectedDataDidBecomeAvailableNotification:) name: UIApplicationProtectedDataDidBecomeAvailable    object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleApplicationDidEnterBackgroundNotification:)   name: UIApplicationDidEnterBackgroundNotification     object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleApplicationWillEnterForegroundNotification:)  name: UIApplicationWillEnterForegroundNotification    object: nil];
#endif
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleConnectivityChangedNotification:)             name: MGNetworkReachabilityChangedNotification        object: nil];
        //
        // Start mointoring the network hosts
        //
        [MGNetworkMonitor start];
        [self start];
        [self setOnline];
    }
    return self;
}

//
// We're suing ARC but we need to clean up other stuff
//
- (void) dealloc {
    [MGNetworkMonitor stop];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    //
    // Deallocate our internal core structure
    //
    CFRelease(((_ICS *)_ics)->settingsByModelPointer);
    CFRelease(((_ICS *)_ics)->dataStoreManagersByModelPointer);
    CFRelease(((_ICS *)_ics)->dataStoreManagersByName);
    free(_ics);
}

#pragma mark - Private Shared Methods

- (void) start {
    
    //
    // Forcing the main thread allows us synchronous
    // access to the active variables and others.
    //
    // If you remove the restriction, you must account for that.
    //
    MGAssertIsMainThread();
    
    if (!((_ICS *)_ics)->active) {

        LogInfo(@"Starting...");
        
        CFIndex       count             = CFDictionaryGetCount(((_ICS *)_ics)->dataStoreManagersByName);
        char       ** dataStoreNames    = (char **) malloc(sizeof(char *) * count);
        const void ** dataStoreManagers = (const void **) malloc(sizeof(MGDataStoreManager *) * count);
        
        CFDictionaryGetKeysAndValues(((_ICS *)_ics)->dataStoreManagersByName, (const void **) dataStoreNames, dataStoreManagers);
        
        for (int i = 0; i < count; i++) {
            [(__bridge MGDataStoreManager *) dataStoreManagers[i] start];
        }

        free(dataStoreNames);
        free(dataStoreManagers);

        ((_ICS *)_ics)->active = YES;
        
        LogInfo(@"Started");
    }
}

- (void) stop {
    
    //
    // Forcing the main thread allows us synchronous
    // access to the active variables and others.
    //
    // If you remove the restriction, you must account for that.
    //
    MGAssertIsMainThread();
    
    if (((_ICS *)_ics)->active) {
        
        LogInfo(@"Stopping...");
        
        CFIndex       count             = CFDictionaryGetCount(((_ICS *)_ics)->dataStoreManagersByName);
        char       ** dataStoreNames    = (char **) malloc(sizeof(char *) * count);
        const void ** dataStoreManagers = (const void **) malloc(sizeof(MGDataStoreManager *) * count);
        
        CFDictionaryGetKeysAndValues(((_ICS *)_ics)->dataStoreManagersByName, (const void **) dataStoreNames, dataStoreManagers);
        
        for (int i = 0; i < count; i++) {
            [(__bridge MGDataStoreManager *) dataStoreManagers[i] stop];
        }
        
        free(dataStoreNames);
        free(dataStoreManagers);
        
        ((_ICS *)_ics)->active = NO;
        
        LogInfo(@"Stopped");
    }
}

- (void) setOnline {
    
    //
    // Forcing the main thread allows us synchronous
    // access to the active variables and others.
    //
    // If you remove the restriction, you must account for that.
    //
    MGAssertIsMainThread();
    
    if (!((_ICS *)_ics)->online) {
        
         LogInfo(@"Going online...");
        
        CFIndex       count             = CFDictionaryGetCount(((_ICS *)_ics)->dataStoreManagersByName);
        char       ** dataStoreNames    = (char **) malloc(sizeof(char *) * count);
        const void ** dataStoreManagers = (const void **) malloc(sizeof(MGDataStoreManager *) * count);
        
        CFDictionaryGetKeysAndValues(((_ICS *)_ics)->dataStoreManagersByName, (const void **) dataStoreNames, dataStoreManagers);
        
        for (int i = 0; i < count; i++) {
            [(__bridge MGDataStoreManager *) dataStoreManagers[i] setOnline];
        }
        
        free(dataStoreNames);
        free(dataStoreManagers);
        
        ((_ICS *)_ics)->online = YES;
        
        LogInfo(@"Now online");
    }
}

- (void) setOffline {
    
    //
    // Forcing the main thread allows us synchronous
    // access to the active variables and others.
    //
    // If you remove the restriction, you must account for that.
    //
    MGAssertIsMainThread();
    
    if (((_ICS *)_ics)->online) {
        
        LogInfo(@"Going offline...");
        
        CFIndex       count             = CFDictionaryGetCount(((_ICS *)_ics)->dataStoreManagersByName);
        char       ** dataStoreNames    = (char **) malloc(sizeof(char *) * count);
        const void ** dataStoreManagers = (const void **) malloc(sizeof(MGDataStoreManager *) * count);
        
        CFDictionaryGetKeysAndValues(((_ICS *)_ics)->dataStoreManagersByName, (const void **) dataStoreNames, dataStoreManagers);
        
        for (int i = 0; i < count; i++) {
            [(__bridge MGDataStoreManager *) dataStoreManagers[i] setOffline];
        }
        
        free(dataStoreNames);
        free(dataStoreManagers);
        
        ((_ICS *)_ics)->online = NO;
        
        LogInfo(@"Now offline");
    }
}

#pragma mark - Notification Handlers

- (void) handleProtectedDataWillBecomeUnavailable: (NSNotification *) aNotification {
    LogTrace(1, @"Protected data will become unavailable...");
    [self stop];
}

- (void) handleProtectedDataDidBecomeAvailableNotification: (NSNotification *) aNotification {
    LogTrace(1, @"Protected data is available...");
    [self start];
}

- (void)  handleApplicationWillTerminateNotification: (NSNotification *) aNotification {
    LogTrace(1, @"Application will terminate...");
    [self stop];
}

- (void) handleApplicationDidEnterBackgroundNotification: (NSNotification *) aNotification {
    LogTrace(1, @"Application Did Enter background...");
    [self stop];
}

- (void) handleApplicationWillEnterForegroundNotification: (NSNotification *) aNotification {
    LogTrace(1, @"Application Will Enter Foreground...");
    
    //
    // NOTE: WillEnterForground is called before the data is available when coming back
    //       from a locked screen.
    //
    //       We have to make sure that MGConnect is not brought online until the data is available.
    //
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    if ([[UIApplication sharedApplication] isProtectedDataAvailable]) {
        [self start];
    }
#endif
}

- (void) handleConnectivityChangedNotification:(NSNotification *)aNotification {
    
    //
    // Note: MGNetworkMonitor gaurentees the notification will
    //       be called on the main thread so we're protected. 
    //
    MGAssertIsMainThread();
    
    if ([[aNotification object] isKindOfClass: [MGNetworkReachability class]]) {
        
        MGNetworkReachability * currentReachability = [aNotification object];
 
        NSString * host = [[aNotification userInfo] objectForKey: MGNetworkReachabilityNotificationHostKey];
        
        if (!host) {
            host = @"";
        }
        
        switch ([currentReachability currentReachabilityStatus])
        {
            case NotReachable:
                LogWarning(@"Host %@ is currently unreachable, suspending network operations until connectivity is restored", host);
                
                [self setOffline];
                
                break;
            case ReachableViaWWAN:
            case ReachableViaWiFi:
                LogWarning(@"Host %@ is now reachable, resuming network operations", host);
                
                [self setOnline];
                
                break;
        }
    }
}

@end
