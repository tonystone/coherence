//
//  Server+Extensions.m
//  CloudBase
//
//  Created by Tony Stone on 10/10/11.
//  Copyright 2011 Mobile Grid, Inc. All rights reserved.
//

#import "Server+Extensions.h"
#import "CLConstents.h"
#import "Instance.h"

@implementation Server (Extensions)

- (Instance *) currentInstance {
    return [[self valueForKey: @"fetchCurrentInstance"] lastObject];
}
- (Instance *) nextInstance {
    return [[self valueForKey: @"fetchNextInstance"] lastObject];
}
- (BOOL) active {
    return ([self.state integerValue] != instanceStateStopped && [self.state integerValue] != instanceStateInactive);
}

@end
