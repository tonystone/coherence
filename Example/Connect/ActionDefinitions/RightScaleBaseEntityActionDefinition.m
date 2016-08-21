//
//  RightScaleBaseEntityActionDefinition.m
//  MGConnectTest
//
//  Created by Tony Stone on 4/13/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "RightScaleBaseEntityActionDefinition.h"
#import "MGWSDL+HTTP.h"

@implementation RightScaleBaseEntityActionDefinition

- (NSString *) address {
    return @"https://my.rightscale.com/api";
}

- (NSDictionary *) headers {
    return [[NSDictionary alloc] initWithObjectsAndKeys: @"1.5", @"X_API_VERSION", nil];
}

- (BOOL) cookies {
    return YES;
}

- (NSString *) outputSerialization {
    return MGWSDLHTTPExtensionValueSerializationXML;
}

- (id) primaryKey {
    return @"resourceReference";
}

- (NSDictionary *)mapping {
    return @{};
}

@end
