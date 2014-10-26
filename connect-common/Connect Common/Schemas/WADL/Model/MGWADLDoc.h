//
// Created by Tony Stone on 7/9/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGXMLElement.h"

@interface MGWADLDoc : MGXMLElement
    - (NSString *) title;
    - (NSString *) ref;
    - (NSString *) text;
    - (NSDictionary *) otherAttributes;
    - (NSArray *) otherElements;
@end