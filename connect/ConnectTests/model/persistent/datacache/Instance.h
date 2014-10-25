//
//  Instance.h
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DeploymentResource.h"
#import "CLInstance.h"

@interface Instance : DeploymentResource <CLInstance>

@property (nonatomic) NSNumber * state;
@property (nonatomic) NSDate   * launchedAt;
@property (nonatomic) NSDate   * terminatedAt;
@property (nonatomic) NSString * userData;

@property (nonatomic) NSString * parentReference;

@property (nonatomic) NSString * monitoringMetricsReference;
@property (nonatomic) NSString * multiCloudImageReference;
@property (nonatomic) NSString * serverTemplateReference;
@property (nonatomic) NSString * instanceTypeReference;
@property (nonatomic) NSString * volumeAttachmentsReference;
@property (nonatomic) NSString * datacenterReference;
@property (nonatomic) NSString * cloudReference;

// Info section
@property (nonatomic) NSString * osPlatform;
@property (nonatomic) NSString * pricingType;
@property (nonatomic) NSString * price;

@end
