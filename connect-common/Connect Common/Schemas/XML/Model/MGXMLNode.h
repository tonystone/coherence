//
// Created by Tony Stone on 7/10/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MGXMLNode : NSObject

    - (NSArray *) children;
    - (void) addChild: (MGXMLNode *) child;
    - (void) insertChild: (MGXMLNode *) child atIndex: (NSUInteger) index;

    - (NSString *) xmlString: (NSUInteger) level;
@end