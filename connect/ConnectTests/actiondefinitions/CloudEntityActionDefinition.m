//
//  CloudEntityActionDefinition.m
//  MGConnectTest
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "CloudEntityActionDefinition.h"

@implementation CloudEntityActionDefinition

- (NSDictionary *) actionLocations {
    
    return @{MGEntityActionList:   @"/clouds", 
             MGEntityActionRead:   @"/clouds/{cloudID}",
             MGEntityActionInsert: @"/clouds",   
             MGEntityActionUpdate: @"/clouds/{cloudID}", 
             MGEntityActionDelete: @"/clouds/{cloudID}"};
}

@end
