//
//  Server.m
//
//  Created by Tony Stone on 9/14/11.
//  Copyright (c) 2011 Mobile Grid, Inc. All rights reserved.
//

#import "Server.h"

@implementation Server
/*
 
@synthesize nextInstanceReference;
@synthesize currentInstanceReference;
@synthesize stateSection;
@synthesize serverTemplateReference;
@synthesize state;
*/

@dynamic stateName;

@dynamic nextInstanceReference;
@dynamic currentInstanceReference;
@dynamic stateSection;
@dynamic serverTemplateReference;


- (void) setStateName:(NSString *)stateName {
    
    [self setState: [self stringToInstanceState: stateName]];
}

- (NSString *) stateName {
    return [self stringForState: [self state]];
}

- (void) setStateSection:(NSNumber *)stateSection {
    ; // Readonly property, do nothing
}

- (NSString *)state 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"state"];
    tmpValue = [self primitiveValueForKey: @"state"];
    [self didAccessValueForKey:@"state"];
    
    return tmpValue;
}

- (void)setState:(NSNumber *)value
{
    [self willChangeValueForKey:@"state"];
    [self setPrimitiveValue: value forKey:@"state"];
    [self didChangeValueForKey:@"state"];
    
    NSNumber * section = nil;
    
    CLInstanceState state = (CLInstanceState) [[self state] integerValue];
    
    if (state == instanceStateOperational) {
        section = [NSNumber numberWithInt: 0];
    } else if (state == instanceStateStopped || state == instanceStateInactive) {
        section = [NSNumber numberWithInt: 2];
    } else {
        section = [NSNumber numberWithInt: 1];
    }
    
    [self willChangeValueForKey:@"stateSection"];
    [self setPrimitiveValue: section forKey: @"stateSection"];
    [self didChangeValueForKey:@"stateSection"];
}



- (NSNumber *) stringToInstanceState: (NSString *) stateString {
    CLInstanceState state = instanceStateUnknown;
    
    if      ([stateString isEqualToString: @"operational"])         state = instanceStateOperational;
    else if ([stateString isEqualToString: @"stopped"])             state = instanceStateStopped;
    else if ([stateString isEqualToString: @"inactive"])            state = instanceStateInactive;
    else if ([stateString isEqualToString: @"pending"])             state = instanceStatePending;
    else if ([stateString isEqualToString: @"booting"])             state = instanceStateBooting;
    else if ([stateString isEqualToString: @"decommissioning"])     state = instanceStateDecommissioning;
    else if ([stateString isEqualToString: @"configuring"])         state = instanceStateConfiguring;
    else if ([stateString isEqualToString: @"stranded in booting"]) state = instanceStateStranded;
    else if ([stateString isEqualToString: @"shutting-down"])       state = instanceStateShuttingDown;
    else if ([stateString isEqualToString: @"stopping"])            state = instanceStateStopping;
    
    return [NSNumber numberWithInt: state];
}

- (NSString *) stringForState:(NSNumber *)state {
    
    switch ([state integerValue]) {
        case instanceStateOperational:      return @"Operational";
        case instanceStatePending:          return @"Pending";
        case instanceStateBooting:          return @"Booting";
        case instanceStateDecommissioning:  return @"Decommissioning";
        case instanceStateConfiguring:      return @"Configuring";
        case instanceStateShuttingDown:     return @"Shutting down";
        case instanceStateStopping:         return @"Stopping";
        case instanceStateStopped:          return @"Stopped";
        case instanceStateInactive:         return @"Inactive";
        case instanceStateStranded:         return @"Stranded";
        default:                            return @"Unknown";
    }
}

@end
