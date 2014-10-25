//
//  ChildCloudResource+Extensions.h
//  CloudBase
//
//  Created by Tony Stone on 10/8/11.
//  Copyright 2011 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChildCloudResource.h"

@class RootCloudResource;

@interface ChildCloudResource (Extensions)
@property (nonatomic, readonly) RootCloudResource * root;
@end
