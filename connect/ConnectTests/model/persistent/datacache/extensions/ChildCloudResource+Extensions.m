//
//  ChildCloudResource+Extensions.m
//  CloudBase
//
//  Created by Tony Stone on 10/8/11.
//  Copyright 2011 Mobile Grid, Inc. All rights reserved.
//

#import "ChildCloudResource+Extensions.h"
#import "RootCloudResource.h"

@implementation ChildCloudResource (Extensions)
- (RootCloudResource *) root {
    return [[self valueForKey: @"fetchRoot"] lastObject];
}
@end
