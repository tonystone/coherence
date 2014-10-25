//
//  DeploymentResource+Extensions.h
//  CloudBase
//
//  Created by Tony Stone on 10/8/11.
//  Copyright 2011 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeploymentResource.h"

@class Deployment;

@interface DeploymentResource (Extensions)

@property (nonatomic, readonly) Deployment * deployment;

@end
