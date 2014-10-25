//
//  HREntityActionDefinition.m
//  MGConnectTest
//
//  Created by Tony Stone on 4/13/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "HREntityActionDefinition.h"

@implementation HREntityActionDefinition

- (NSString *) address {
    return @"http://localhost/hr/test/rest";
}

- (NSDictionary *) headers {
    return [[NSDictionary alloc] initWithObjectsAndKeys: @"1.0", @"X_API_VERSION", nil];
}

- (BOOL) cookies {
    return YES;
}

- (NSString *) outputSerialization {
    return @"application/xml";
}

- (id) primaryKey {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

@end
