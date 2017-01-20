//
//  MGNetworkMonitor.m
//  MGConnect
//
//  Created by Tony Stone on 3/27/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGNetworkMonitor.h"
#import "MGNetworkReachability.h"
@import TraceLog;

NSString * MGNetworkReachabilityChangedNotification = @"MGNetworkReachabilityChangedNotification";
NSString * MGNetworkReachabilityNotificationHostKey = @"MGNetworkReachabilityNotificationHostKey";

static void reachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info);

static NSCountedSet        * monitoredHosts;
static NSMutableDictionary * reachabilityMonitorsByHost;
static BOOL started;

@implementation MGNetworkMonitor

+ (void) initialize {
    
    if (self == [MGNetworkMonitor class]) {

        LogInfo(@"Initializing network monitoring service...");
        
        monitoredHosts             = [[NSCountedSet alloc] init];
        reachabilityMonitorsByHost = [[NSMutableDictionary alloc] init];
        
        started = NO;
        
        LogInfo(@"Network monitoring service initialized");
    }
}

+ (void) start {
    
    @synchronized (self) {
        if (!started) {
            
            LogInfo(@"Starting network monitoring service...");
            
            for (NSString * host in monitoredHosts) {
                [self startMonitorForHost: host];
            }
            started = YES;
            
            LogInfo(@"Network monitoring service started");
        }
    }
}

+ (void) stop {
    
    @synchronized (self) {
        if (started) {
            
            LogInfo(@"Stopping network monitoring service...");
            
            for (NSString * host in monitoredHosts) {
                [self stopMonitorForHost: host];
            }
            started = NO;
            
            LogInfo(@"Network monitoring service stopped");
        }
    }
}

+ (void) addMonitoredHost: (NSString *) host {
    
    @synchronized (self) {
        
        //
        // Add to the counted set. It will increment
        // the count if it is already there.
        //
        [monitoredHosts addObject: host];
        
        //
        // Check for an existing reachability monitor
        //
        // If none exist, we'll need to create one
        //
        MGNetworkReachability  * reachabilityMonitor = [reachabilityMonitorsByHost objectForKey: host];
        
        if (!reachabilityMonitor) {
            reachabilityMonitor = [MGNetworkReachability reachabilityWithHostName: host];
            
            [reachabilityMonitorsByHost setObject: reachabilityMonitor forKey: host];
            
            //
            // If we're started, we need
            // to start this instance of the
            // reachability monitor since we
            // created it above
            //
            if (started) {
                [self startMonitorForHost: host];
            }
            
        }
    }
}

+ (void) removeMonitoredHost:(NSString *)host {
    
    @synchronized (self) {
        
        [monitoredHosts removeObject: host];
        
        if ([monitoredHosts countForObject: host] == 0) {
            
            if ([reachabilityMonitorsByHost objectForKey: host]) {
                
                //
                // If we're started, we can assume
                // that the hostReacability monitor is active
                // and needs to be shutdown
                //
                if (started) {
                    [self stopMonitorForHost: host];
                }
                [reachabilityMonitorsByHost removeObjectForKey: host];
            }
        }
    }
}

+ (void) startMonitorForHost: (NSString *) host {
    
    MGNetworkReachability * reachabilityMonitor = [reachabilityMonitorsByHost objectForKey: host];
    
    if ([NSThread isMainThread]) {
        [reachabilityMonitor startNotifier: reachabilityCallback];
    } else {
        __block NSException * anException = nil;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            @try {
                [reachabilityMonitor startNotifier: reachabilityCallback];
            }
            @catch (NSException *exception) {
                anException = exception;
            }
        });
        
        if (anException) {
            @throw anException;
        }
    }
    LogTrace(1, @"Started monitoring of host <%@>", host);
}

+ (void) stopMonitorForHost: (NSString *) host {
 
    MGNetworkReachability * reachabilityMonitor = [reachabilityMonitorsByHost objectForKey: host];
    
    if ([NSThread isMainThread]) {
        [reachabilityMonitor stopNotifier];
    } else {
        __block NSException * anException = nil;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            @try {
                [reachabilityMonitor stopNotifier];
            }
            @catch (NSException *exception) {
                anException = exception;
            }
        });
        
        if (anException) {
            @throw anException;
        }
    }
    LogTrace(1, @"Stopped monitoring of host <%@>", host);
}

@end

static void reachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
#pragma unused (target, flags)
    
	NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
	NSCAssert([(__bridge NSObject*) info isKindOfClass: [MGNetworkReachability class]], @"info was wrong class in ReachabilityCallback");
    
    NSDictionary          * userInfo           = nil;
    MGNetworkReachability * reachabilityObject = (__bridge MGNetworkReachability *) info;
    
    //
    // Find the reachability objects host
    //
    NSSet * hosts = [reachabilityMonitorsByHost keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {

        // Stop on the first matching obect
        return *stop = obj == reachabilityObject;
    }];
    
    if ([hosts count] > 0) {
        // NOTE: We can use [hosts anyObject] here because there should only be one object
        userInfo = [[NSDictionary alloc] initWithObjectsAndKeys: [hosts anyObject], MGNetworkReachabilityNotificationHostKey, nil];
    }
    
    //
    // Post a notification to notify the
    // client that the network reachability changed.
    //
    // NOTE: Since we start all reachability monitors on the main thread,
    //       we don't have to do anything special here to get it on the main thread.
    //
    [[NSNotificationCenter defaultCenter] postNotificationName: MGNetworkReachabilityChangedNotification object: reachabilityObject userInfo: userInfo];
}
