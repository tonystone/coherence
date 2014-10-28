//
// Created by Tony Stone on 7/2/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnect.h"
#import <CoreData/CoreData.h>
#import <MGConnectCommon/MGTraceLog.h>

#import "MGConnectInitializationOptions.h"

//#import "MGInMemoryPersistentStore.h"
//#import "MGSQLitePersistentStore.h"

//#import "MGNetworkMonitor.h"

//#import "MGConnectPersistentStoreCoordinator+Internal.h"


NSString * const MGInMemoryStoreType  = @"MGInMemoryPersistentStore"; // [MGInMemoryPersistentStore storeType];
NSString * const MGSQLiteStoreType    = @"MGSQLitePersistentStore"; // [MGSQLitePersistentStore storeType];

//
//  Private internal Objective-C interface.
//
@interface MGConnect (Private)

//    + (void) registerPersistentStoreClass: (Class <MGPersistentStore>) aPersistentStoreClass;
@end

//
// Main external Objective-C interface.
//
@implementation MGConnect

    // This is a singleton
    static MGConnect * instance;

    + (void)initializeWithOptions: (NSDictionary *) options {

        //
        // Note, we limit locks in Connect but
        // this must be synchronized and since
        // it's only ever done once, we can
        // safely use locking here.
        //
        @synchronized (instance) {

            if (!instance) {
            
                LogInfo(@"[version %@] Initializing...", MGStringFromVersion([[self class] versionInfo]));

                [MGConnectInitializationOptions overrideOptions: options];

                // Create the singleton object
                instance = [[MGConnect alloc] init];

                //
                // Register all the persistent store types
                //
//                [self registerPersistentStoreClass: [MGInMemoryPersistentStore class]];
//                [self registerPersistentStoreClass: [MGSQLitePersistentStore   class]];
            } else {
                @throw [NSException exceptionWithName: @"Initialization exception" reason: [NSString stringWithFormat: @"%@ already initialized, it can not be initialized more than once.", NSStringFromClass([self class])] userInfo: nil];
            }
        }
    }

    + (MGVersion) versionInfo {
        return MGMakeVersion(MGConnectVersion_MAJOR, MGConnectVersion_MINOR, MGConnectVersion_BUILD);
    }

    + (MGConnect *) instance {
        return instance;
    }

@end

@implementation MGConnect (Private)

#pragma mark - Class Methods

//    + (void) registerPersistentStoreClass: (Class <MGPersistentStore>) aPersistentStoreClass {
//
//        [NSPersistentStoreCoordinator registerStoreClass: aPersistentStoreClass forStoreType: [aPersistentStoreClass storeType]];
//        
//        LogInfo(@"PersistentStoreType \"%@\" registered.", [aPersistentStoreClass storeType]);
//    }

@end


@implementation MGConnect (NSApplication)

    - (void) start {

    }

    - (void) stop {

    }

    - (BOOL) online {
        return YES;
    }

    - (void) setOnline: (BOOL) isOnline {

    }

    - (void) handleProtectedDataWillBecomeUnavailable: (NSNotification *)aNotification {
        LogTrace(4, @"Protected data will become unavailable...");
        
        [self stop];
    }

    - (void) handleProtectedDataDidBecomeAvailableNotification: (NSNotification *)aNotification {
        LogTrace(4, @"Protected data is available...");
        
        [self start];
    }

    - (void)  handleApplicationWillTerminateNotification: (NSNotification *)aNotification {
        LogTrace(4, @"Application will terminate...");
        
        [self stop];
    }

    - (void) handleApplicationDidEnterBackgroundNotification: (NSNotification *)aNotification {
        LogTrace(4, @"Application Did Enter background...");

        [self stop];
    }

    - (void) handleApplicationWillEnterForegroundNotification: (NSNotification *)aNotification {
        LogTrace(4, @"Application Will Enter Foreground...");

        //
        // NOTE: WillEnterForeground is called before
        //       the data is available when coming back
        //       from a locked screen.
        //
        //       We have to make sure that Connect is
        //       not brought online until the data is available.
        //
//#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
//    if ([[UIApplication sharedApplication] isProtectedDataAvailable]) {
        [self start];
//    }
//#endif
    }

#pragma mark - Notification Handlers

//    - (void) handleConnectivityChangedNotification:(NSNotification *)aNotification {
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            if ([[aNotification object] isKindOfClass: [MGNetworkReachability class]]) {
//
//                MGNetworkReachability * currentReachability = [aNotification object];
//
//                NSParameterAssert([currentReachability isKindOfClass: [MGNetworkReachability class]]);
//
//                switch ([currentReachability currentReachabilityStatus])
//                {
//                    case NotReachable:
//                        LogInfo(@"Network connectivity is currently unreachable, suspending network operations until connectivity is restored");
//
//                        [self setOnline: NO];
//
//                        break;
//                    case ReachableViaWWAN:
//                    case ReachableViaWiFi:
//                        LogInfo(@"The network is currently reachable, resuming network operations");
//
//                        [self setOnline: YES];
//
//                        break;
//                }
//            }
//        });
//    }

@end
