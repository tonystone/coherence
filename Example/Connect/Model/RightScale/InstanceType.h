//
//  InstanceType.h
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Resource.h"

@interface InstanceType : Resource

@property (nonatomic) NSString * cloudReference;
@property (nonatomic) NSString * memory;
@property (nonatomic) NSString * cpuArchitecture;
@property (nonatomic) NSString * cpuCount;
@property (nonatomic) NSString * cpuSpeed;
@property (nonatomic) NSString * localDisks;
@property (nonatomic) NSString * localDiskSize;
@property (nonatomic) NSString * resourceUid;

@end
