//
//  Deployment.h
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AuditedResource.h"

@interface Deployment : AuditedResource

@property (nonatomic) NSString * inputsReference;
@property (nonatomic) NSString * serversReference;
@property (nonatomic) NSString * serverArraysReference;

@end
