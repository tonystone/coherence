//
//  DatacenterEntityActionDefinition.m
//  MGConnectTest
//
//  Created by Tony Stone on 4/13/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "DatacenterEntityActionDefinition.h"

@implementation DatacenterEntityActionDefinition

- (NSDictionary *) actionLocations {
    
    return @{MGEntityActionList:   @"/clouds/{cloudID}/datacenters",                
             MGEntityActionRead:   @"/clouds/{cloudID}/datacenters/{datacenterID}",
             MGEntityActionInsert: @"/clouds/{cloudID}/datacenters",                
             MGEntityActionUpdate: @"/clouds/{cloudID}/datacenters/{datacenterID}",
             MGEntityActionDelete: @"/clouds/{cloudID}/datacenters/{datacenterID}"};

}

@end
