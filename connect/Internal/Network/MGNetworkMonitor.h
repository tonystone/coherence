//
//  MGNetworkMonitor.h
//  MGConnect
//
//  Created by Tony Stone on 3/27/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGNetworkReachability.h"

extern NSString * MGNetworkReachabilityChangedNotification;
extern NSString * MGNetworkReachabilityNotificationHostKey;

@interface MGNetworkMonitor : NSObject

/**
 Start the reachability monitoring
 */
+ (void) start;

/**
 Stop reachability monitoring
 */
+ (void) stop;

/**
 Add the host to the monitoring table and start monitorig if monitoring is started.
 */
+ (void) addMonitoredHost: (NSString *) host;

/**
 Remove the host from the monitoring table and stop monitoring it.
 */
+ (void) removeMonitoredHost: (NSString *) host;

@end
