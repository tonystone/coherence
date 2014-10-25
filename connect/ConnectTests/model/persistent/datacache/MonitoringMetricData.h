//
//  MonitoringMetricData.h
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Resource.h"
#import "CLMonitoringMetricData.h"

@interface MonitoringMetricData : Resource <CLMonitoringMetricData>

@property (nonatomic) id metricVariableData;
@property (nonatomic) NSDate * start;
@property (nonatomic) NSDate * end;
@property (nonatomic) NSString * monitoringMetricReference;

@end
