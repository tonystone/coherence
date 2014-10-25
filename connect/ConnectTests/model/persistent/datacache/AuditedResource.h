//
//  AuditedResource.h
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Resource.h"

@interface AuditedResource : Resource 

@property (nonatomic) NSString * createdBy;
@property (nonatomic) NSDate   * createdAt;
@property (nonatomic) NSString * updatedBy;
@property (nonatomic) NSDate   * updatedAt;

@end
