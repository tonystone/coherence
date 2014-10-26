//
// Created by Tony Stone on 7/9/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGXMLElement.h"

@interface MGWADLResponse : MGXMLElement
    - (NSUInteger) status;
    - (NSDictionary *) otherAttributes;
    - (NSArray *) docs;
    - (NSArray *) params;
    - (NSArray *) representations;
    - (NSArray *) otherElements;
@end