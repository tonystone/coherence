//
// Created by Tony Stone on 7/10/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGXMLNode.h"

@interface MGXMLCDATA : MGXMLNode

    - (instancetype)initWithData:(NSData *)aCDATABlock;
    + (instancetype)cdataWithData:(NSData *)aCDATABlock;
    - (NSString *)xmlString:(NSUInteger)level;

@end