//
//  InstanceEntityActionDefinition.m
//  MGConnectTest
//
//  Created by Tony Stone on 4/13/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "InstanceEntityActionDefinition.h"

@implementation InstanceEntityActionDefinition

- (NSDictionary *) actionLocations {
    
    return @{MGEntityActionList:      @"/clouds/{cloudID}/instances",
             MGEntityActionRead:      @"/clouds/{cloudID}/instances/{instanceID}",
             MGEntityActionInsert:    @"/clouds/{cloudID}/instances",
             MGEntityActionUpdate:    @"/clouds/{cloudID}/instances/{instanceID}",
             MGEntityActionDelete:    @"/clouds/{cloudID}/instances/{instanceID}",
             @"launch":    @{@"POST": @"/clouds/{cloudID}/instances/{instanceID}/launch"},
             @"reboot":    @{@"POST": @"/clouds/{cloudID}/instances/{instanceID}/reboot"},
             @"terminate": @{@"POST": @"/clouds/{cloudID}/instances/{instanceID}/terminate"},
             @"start":     @{@"POST": @"/clouds/{cloudID}/instances/{instanceID}/start"},   
             @"stop":      @{@"POST": @"/clouds/{cloudID}/instances/{instanceID}/stop"}};
}

@end
