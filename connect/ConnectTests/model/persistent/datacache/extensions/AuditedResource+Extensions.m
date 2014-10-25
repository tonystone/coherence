//
//  AuditedResource+Extensions.m
//  CloudBase
//
//  Created by Tony Stone on 10/11/11.
//  Copyright 2011 Mobile Grid, Inc. All rights reserved.
//

#import "AuditedResource+Extensions.h"

@implementation AuditedResource (Extensions)

- (NSArray *) inputs {
    return [self valueForKey: @"fetchInputs"];
}

@end
