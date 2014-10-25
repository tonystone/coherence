//
// Created by Tony Stone on 7/2/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnect.h"
#import <CoreData/CoreData.h>
#import "MGInMemoryPersistentStore.h"
#import "MGSQLitePersistentStore.h"

#import <CoreData/CoreData.h>

#import "MGConnect.h"
#import "MGTraceLog.h"
#import "MGNetworkMonitor.h"
#import "MGConnectInitializationOptions.h"

#import "MGActionMonitorNotificationManager.h"
#import "MGConnectAction.h"
#import "MGConnectPersistentStoreCoordinator+Internal.h"

#include "Connect.hpp"
#include <Common/LogStream.h>
#include <map>

using namespace mg;

NSString * const MGInMemoryStoreType  = [MGInMemoryPersistentStore storeType];
NSString * const MGSQLiteStoreType    = [MGSQLitePersistentStore storeType];

//NSString * const MGConnectMainThreadManagedObjectContextLimitOption = @"contextLimit";
//NSString * const MGConnectTakeOverCoreDataOption                    = @"takeOverCoreData";

//
//  Private internal Objective-C interface.
//
@interface MGConnect (Private)

    + (void) registerPersistentStoreClass: (Class <MGPersistentStore>) aPersistentStoreClass;
    - (instancetype) initWithOptions: (NSDictionary *) options;
@end

//
// Main external Objective-C interface.
//
@implementation MGConnect {
        Connect * impl;
    }

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
                LogStream::cout = LogStream("Connect", LogStream::LogLevel::INFO);

                LogStream::cout << LogStream::INFO << "[version " << [[self class] versionInfo] << "] Initializing..." << std::endl;

                // FIXME - Old code - This is just temporary until the conversion to the new code is done..
                [MGConnectInitializationOptions overrideOptions: options];

                // Create the singleton object
                instance = [[MGConnect alloc] initWithOptions: options];

                //
                // Register all the persistent store types
                //
                [self registerPersistentStoreClass: [MGInMemoryPersistentStore class]];
                [self registerPersistentStoreClass: [MGSQLitePersistentStore   class]];
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

    - (id) init {
        [self doesNotRecognizeSelector: _cmd];

        return nil;
    }

    + (void) registerActionDefinition: (id <MGConnectEntityActionDefinition>) actionDefinition forEntity: (NSEntityDescription *) entity persistentStoreCoordinator: (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

        NSParameterAssert(entity != nil);
        NSParameterAssert(actionDefinition != nil);
        NSParameterAssert(persistentStoreCoordinator != nil);
        NSParameterAssert([persistentStoreCoordinator isKindOfClass: [MGConnectPersistentStoreCoordinator class]]);

        [(MGConnectPersistentStoreCoordinator *) persistentStoreCoordinator addManageEntity: entity actionDefinition: actionDefinition];
    }


    + (void) registerActionMonitor: (id <MGConnectActionMonitor>) monitor {

        NSParameterAssert(monitor != nil);

        [[MGActionMonitorNotificationManager sharedManager] registerActionMonitor: monitor];
    }

    + (void) registerActionMonitor: (id <MGConnectActionMonitor>) monitor forEntity: (NSEntityDescription *) entity {

        NSParameterAssert(monitor != nil);
        NSParameterAssert(entity != nil);

        [[MGActionMonitorNotificationManager sharedManager] registerActionMonitor: monitor forEntity: entity];
    }

@end

@implementation MGConnect (Private)

#pragma mark - Class Methods

    + (void) registerPersistentStoreClass: (Class <MGPersistentStore>) aPersistentStoreClass {

        [NSPersistentStoreCoordinator registerStoreClass: aPersistentStoreClass forStoreType: [aPersistentStoreClass storeType]];
        LogStream::cout << LogStream::INFO << "PersistentStoreType \"" << [[aPersistentStoreClass storeType] cStringUsingEncoding: NSUTF8StringEncoding] << "\" registered." << std::endl;
    }

#pragma mark - Instance Methods

    - (instancetype) initWithOptions: (NSDictionary *) optionsDictionary {

        self = [super init];
        if (self) {
            Connect::Options options = [self optionsDictionaryToOptions: optionsDictionary];

             impl = new Connect(options);
        }
        return self;
    }

    - (Connect::Options) optionsDictionaryToOptions: (NSDictionary *) optionsDictionary {
        Connect::Options options;

        for (NSString * key in [optionsDictionary allKeys]) {
            if ([key isEqualToString: MGConnectMainThreadManagedObjectContextLimitOption]) {

                id value = [optionsDictionary objectForKey: key];

                if ([value isKindOfClass: [NSNumber class]]) {
                    options.contextLimit([value unsignedIntValue]);
                }
            } else if ([key isEqualToString: MGConnectTakeOverCoreDataOption]) {

                id value = [optionsDictionary objectForKey: key];

                if ([value isKindOfClass: [NSNumber class]]) {
                    options.takeOverCoreData([value unsignedIntValue]);
                }
            }
        }
        return options;
    }

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
        LogStream::cout << LogStream::LogLevel::TRACE << "Protected data will become unavailable..." << std::endl;
        [self stop];
    }

    - (void) handleProtectedDataDidBecomeAvailableNotification: (NSNotification *)aNotification {
        LogStream::cout << LogStream::LogLevel::TRACE << "Protected data is available..." << std::endl;
        [self start];
    }

    - (void)  handleApplicationWillTerminateNotification: (NSNotification *)aNotification {
        LogStream::cout << LogStream::LogLevel::TRACE << "Application will terminate..." << std::endl;
        [self stop];
    }

    - (void) handleApplicationDidEnterBackgroundNotification: (NSNotification *)aNotification {
        LogStream::cout << LogStream::LogLevel::TRACE << "Application Did Enter background..." << std::endl;
        [self stop];
    }

    - (void) handleApplicationWillEnterForegroundNotification: (NSNotification *)aNotification {
        LogStream::cout << LogStream::LogLevel::TRACE << "Application Will Enter Foreground..." << std::endl;

        //
        // NOTE: WillEnterForground is called before
        //       the data is available when coming back
        //       from a locked screen.
        //
        //       We have to make sure that RM is
        //       not brought online until the data is available.
        //
//#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
//    if ([[UIApplication sharedApplication] isProtectedDataAvailable]) {
        [self start];
//    }
//#endif
    }

#pragma mark - Notification Handlers

    - (void) handleConnectivityChangedNotification:(NSNotification *)aNotification {

        dispatch_async(dispatch_get_main_queue(), ^{

            if ([[aNotification object] isKindOfClass: [MGNetworkReachability class]]) {

                MGNetworkReachability * currentReachability = [aNotification object];

                NSParameterAssert([currentReachability isKindOfClass: [MGNetworkReachability class]]);

                switch ([currentReachability currentReachabilityStatus])
                {
                    case NotReachable:
                        LogStream::cout << LogStream::INFO << "Network connectivity is currently unreachable, suspending network operations until connectivity is restored" << std::endl;

                        [self setOnline: NO];

                        break;
                    case ReachableViaWWAN:
                    case ReachableViaWiFi:
                        LogStream::cout << LogStream::INFO << "The network is currently reachable, resuming network operations" << std::endl;

                        [self setOnline: YES];

                        break;
                }
            }
        });
    }

@end
