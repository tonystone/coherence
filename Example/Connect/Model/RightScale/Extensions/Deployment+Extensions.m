//
//  Deployment+Extensions.m
//  CloudBase
//
//  Created by Tony Stone on 10/10/11.
//  Copyright 2011 Mobile Grid, Inc. All rights reserved.
//

#import "Deployment+Extensions.h"

@implementation Deployment (Extensions)
- (NSArray *) servers {
    return [self valueForKey: @"fetchServers"];
}
- (NSArray *) serverArrays {
    return [self valueForKey: @"fetchServerArrays"];
}
@end
