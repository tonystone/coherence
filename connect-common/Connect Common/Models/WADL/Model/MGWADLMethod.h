//
// Created by Tony Stone on 7/9/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGXMLElement.h"

@class MGWADLRequest;

@interface MGWADLMethod : MGXMLElement
    - (NSString *) eid;
    - (NSString *) name;
    - (NSString *) href;
    - (NSDictionary *) otherAttributes;
    - (NSArray *) docs;
    - (MGWADLRequest *) request;
    - (NSArray *) responses;
    - (NSArray *) otherElements;
@end