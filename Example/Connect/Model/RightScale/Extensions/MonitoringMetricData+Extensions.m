//
//  MonitoringMetricData+Extensions.m
//  CloudBase
//
//  Created by Tony Stone on 11/8/11.
//  Copyright (c) 2011 Mobile Grid, Inc. All rights reserved.
//

#import "MonitoringMetricData+Extensions.h"
#import "MonitoringMetric.h"

@implementation MonitoringMetricData (Extensions)

- (MonitoringMetric *) monitoringMetric {
    return [[self valueForKey: @"fetchMonitoringMetric"] lastObject];
}

@end
