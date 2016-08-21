//
//  ServerArray.h
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DeploymentResource.h"

@interface ServerArray : DeploymentResource

@property (nonatomic) NSString * arrayType;
@property (nonatomic) NSNumber * instanceCount;
@property (nonatomic) NSString * serverTemplateReference;
@property (nonatomic) NSString * nextInstanceReference;
@property (nonatomic) NSString * currentInstancesReference;
@property (nonatomic) NSNumber * enabled;

@end
