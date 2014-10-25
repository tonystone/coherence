//
//  Instance+Extensions.m
//  CloudBase
//
//  Created by Tony Stone on 10/11/11.
//  Copyright 2011 Mobile Grid, Inc. All rights reserved.
//

#import "Instance+Extensions.h"
#import "CLConstents.h"

@implementation Instance (Extensions)
- (Cloud *) cloud {
    return [[self valueForKey: @"fetchCloud"] lastObject];
}
- (Datacenter *) datacenter {
    return [[self valueForKey: @"fetchDatacenter"] lastObject];
}
- (InstanceType *) instanceType {
    return [[self valueForKey: @"fetchInstanceType"] lastObject];
}
- (MonitoringMetrics *) monitoringMetrics {
    return [[self valueForKey: @"fetchMonitoringMetrics"] lastObject];
}
- (MultiCloudImage *) multiCloudImage {
    return [[self valueForKey: @"fetchMultiCloudImage"] lastObject];
}
- (Resource *) parent {
    return [[self valueForKey: @"fetchParent"] lastObject];
}
- (ServerTemplate *) serverTemplate {
    return [[self valueForKey: @"fetchServerTemplate"] lastObject];
}
- (NSArray *) volumeAttachments {
    return [self valueForKey: @"fetchVolumeAttachments"];
}

- (BOOL) active {
    return ([self.state integerValue] != instanceStateStopped && [self.state integerValue] != instanceStateInactive);
}

@end
