//
// Created by Tony Stone on 7/9/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGXMLElement.h"

@interface MGWADLResource : MGXMLElement
    - (NSString *) eid;
    - (NSString *) type;
    - (NSString *) queryType;
    - (NSString *) path;
    - (NSDictionary *) otherAttributes;
    - (NSArray *) docs;
    - (NSArray *) params;
    - (NSArray *) methods;
    - (NSArray *) resources;
    - (NSArray *) otherElements;
@end