//
//  Datacenter.h
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Resource.h"
#import "CLDatacenter.h"

@interface Datacenter : Resource <CLDatacenter>

@property (nonatomic) NSString * cloudReference;
@property (nonatomic) NSString * resourceUid;

@end
