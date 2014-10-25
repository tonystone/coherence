//
//  VersionedResource.h
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AuditedResource.h"
#import "CLVersionedResource.h"

@interface VersionedResource : AuditedResource <CLVersionedResource>

@property (nonatomic) NSNumber * version;
@property (nonatomic) NSNumber * isHeadRevision;

@end
