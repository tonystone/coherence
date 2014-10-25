//
//  DeploymentEntityActionDefinition.m
//  MGConnectTest
//
//  Created by Tony Stone on 4/13/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "DeploymentEntityActionDefinition.h"

@implementation DeploymentEntityActionDefinition

- (NSDictionary *) actionLocations {
    
    return @{MGEntityActionList:   @"/deployments",              
             MGEntityActionInsert: @"/deployments",              
             MGEntityActionUpdate: @"/deployments/{deploymentID}",
             MGEntityActionDelete: @"/deployments/{deploymentID}",
             @"clone":  @{@"POST": @"/deployments/{deploymentID}/clone"}};
}

@end
