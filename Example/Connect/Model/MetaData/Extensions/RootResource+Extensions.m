//
//  RootResource+Extensions.m
//  CloudBase
//
//  Created by Tony Stone on 11/5/11.
//  Copyright (c) 2011 Mobile Grid, Inc. All rights reserved.
//

#import "RootResource+Extensions.h"

@implementation RootResource (Extensions)
- (NSArray *) childResources {
    return [self valueForKey: @"fetchChildResources"];
}

- (GlobalSettings *) globalSettings {
    return [[self valueForKey: @"fetchGlobalSettings"] lastObject];
}
@end
