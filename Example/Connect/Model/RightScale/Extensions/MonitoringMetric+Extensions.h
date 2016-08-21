//
//  MonitoringMetric+Extensions.h
//  CloudBase
//
//  Created by Tony Stone on 11/4/11.
//  Copyright (c) 2011 Mobile Grid, Inc. All rights reserved.
//

#import "MonitoringMetric.h"

@class MonitoringMetricData;
@class GraphViewTemplate;
@class Instance;

@interface MonitoringMetric (Extensions)

- (MonitoringMetricData *) data;
- (GraphViewTemplate *) graphViewTemplate;
- (Instance *) instance;

@end
