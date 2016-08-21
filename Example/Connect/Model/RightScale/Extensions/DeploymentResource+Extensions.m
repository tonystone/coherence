//
//  DeploymentResource+Extensions.m
//  CloudBase
//
//  Created by Tony Stone on 10/8/11.
//  Copyright 2011 Mobile Grid, Inc. All rights reserved.
//

#import "DeploymentResource+Extensions.h"

@implementation DeploymentResource (Extensions)
- (Deployment *) deployment {
    return [[self valueForKey: @"fetchDeployment"] lastObject];
}
@end
