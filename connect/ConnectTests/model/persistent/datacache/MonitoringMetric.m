//
//  MonitoringMetric.m
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import "MonitoringMetric.h"


@implementation MonitoringMetric

@dynamic plugin;
@dynamic period;
@dynamic pluginType;
@dynamic autoRefresh;
@dynamic graphImageReference;
@dynamic defaultPosition;
@dynamic autoRefreshInterval;
@dynamic instanceReference;
@dynamic userPosition;

- (void) setDefaultPosition:(NSNumber *)defaultPosition 
{
    [self willChangeValueForKey:@"defaultPosition"];
    [self setPrimitiveValue: defaultPosition forKey:@"defaultPosition"];
    [self didChangeValueForKey:@"defaultPosition"];
    
    if (![self primitiveValueForKey: @"userPosition"]) {
        [self willChangeValueForKey:@"userPosition"];
        [self setPrimitiveValue: defaultPosition forKey: @"userPosition"];
        [self didChangeValueForKey:@"userPosition"];
    }
}

@end
