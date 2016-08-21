//
//  Cloud.h
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Resource.h"

@interface Cloud : Resource

@property (nonatomic) NSString * instanceTypesReference;
@property (nonatomic) NSString * datacentersReference;

@end
