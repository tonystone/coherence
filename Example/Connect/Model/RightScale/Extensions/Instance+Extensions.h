//
//  Instance+Extensions.h
//  CloudBase
//
//  Created by Tony Stone on 10/11/11.
//  Copyright 2011 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Instance.h"

@class Cloud;
@class Datacenter;
@class InstanceType;
@class MonitoringMetrics;
@class MultiCloudImage;
@class Resource;
@class ServerTemplate;

@interface Instance (Extensions)

- (Cloud *) cloud;
- (Datacenter *) datacenter;
- (InstanceType *) instanceType;
- (MonitoringMetrics *) monitoringMetrics;
- (MultiCloudImage *) multiCloudImage;
- (Resource *) parent;
- (ServerTemplate *) serverTemplate;
- (NSArray *) volumeAttachments;

- (BOOL) active;

@end
