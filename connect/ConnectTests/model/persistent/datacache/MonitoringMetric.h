//
//  MonitoringMetric.h
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Resource.h"
#import "CLMonitoringMetric.h"

@interface MonitoringMetric : Resource <CLMonitoringMetric>

// CLMonitoringMetric Properties
@property (nonatomic) NSString * plugin;
@property (nonatomic) NSString * pluginType;
@property (nonatomic) NSString * graphImageReference;
@property (nonatomic) NSNumber * defaultPosition;

@property (nonatomic) NSString * instanceReference;

// Additional Properties
@property (nonatomic) NSNumber * userPosition;
@property (nonatomic) NSString * period;
@property (nonatomic) NSNumber * autoRefresh;
@property (nonatomic) NSNumber * autoRefreshInterval;

@end
