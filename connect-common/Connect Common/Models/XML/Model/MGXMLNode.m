//
// Created by Tony Stone on 7/10/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGXMLNode.h"

@interface MGXMLNode ()

    - (NSString *) xmlString: (NSUInteger) level;
@end

@implementation MGXMLNode {
        NSMutableArray * _children;
    }

    - (instancetype)init {
        self = [super init];
        if (self) {
            _children = [[NSMutableArray alloc] init];
        }
        return self;
    }

    - (NSArray *) children {
        return _children;
    }

    -(void) addChild: (MGXMLNode *) child {
        [_children addObject: child];
    }

    -(void) insertChild: (MGXMLNode *) child atIndex: (NSUInteger) index {
        [_children insertObject: child atIndex: index];
    }

    - (NSString *)xmlString:(NSUInteger)level {
        NSMutableString * xmlString = [[NSMutableString alloc] init];

        for (MGXMLNode * node in [self children] ) {
            [xmlString appendFormat: @"\r\n%@", [node xmlString: level+1]];
        }
        return xmlString;
    }

@end