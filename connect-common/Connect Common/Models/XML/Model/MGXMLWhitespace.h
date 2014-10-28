//
// Created by Tony Stone on 7/10/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGXMLNode.h"

@interface MGXMLWhitespace : MGXMLNode

    - (instancetype)initWithText:(NSString *)aText;
    + (instancetype)whitespaceWithText:(NSString *)aText;
@end