//
//  Cloud+Extensions.m
//  CloudBase
//
//  Created by Tony Stone on 10/11/11.
//  Copyright 2011 Mobile Grid, Inc. All rights reserved.
//

#import "Cloud+Extensions.h"

@implementation Cloud (Extensions)
- (NSArray *) datacenters {
    return [self valueForKey: @"fetchDatacenters"];
}
- (NSArray *) instanceTypes {
    return [self valueForKey: @"fetchInstanceTypes"];
}
@end
