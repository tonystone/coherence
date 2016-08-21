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

@interface VersionedResource : AuditedResource

@property (nonatomic) NSNumber * version;
@property (nonatomic) NSNumber * isHeadRevision;

@end
