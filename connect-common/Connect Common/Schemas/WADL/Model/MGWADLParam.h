//
// Created by Tony Stone on 7/9/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGXMLElement.h"

@interface MGWADLParam : MGXMLElement
    - (NSString *) eid;
    - (NSString *) href;
    - (NSString *) name;
    - (NSString *) style;
    - (NSString *) type;
    - (NSString *) defaultValue;
    - (BOOL)  required;
    - (BOOL)  repeating;
    - (NSString *) fixed;
    - (NSString *) path;
    - (NSDictionary *) otherAttributes;
    - (NSArray *) docs;
    - (NSArray *) options;
    - (NSArray *) links;
    - (NSArray *) otherElements;
@end