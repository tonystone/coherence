//
// Created by Tony Stone on 7/9/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGWADLResources.h"
#import "MGXMLElementDefinition.h"

@implementation MGWADLResources

    static MGXMLElementDefinition * definition = nil;

    + (void)load {
        definition = [[MGXMLElementDefinition alloc]
                initWithAttributeNames: @[
                        @"base",
                        @"##other"
                ]
                          elementNames:@[
                                  @"doc",
                                  @"resource",
                                  @"##other"
                          ]
        ];
    }

    - (instancetype)initWithName:(NSString *)name qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI {
        self = [super initWithName:name qualifiedName:qualifiedName namespaceURI:namespaceURI definition: definition];

        return self;
    }

    - (NSString *)base {
        return [[self attributes] objectForKey: @"base"];
    }

    - (NSDictionary *)otherAttributes {
        return [super otherAttributes];
    }

    - (NSArray *)docs {
        return [self elementsWithName: @"doc"];
    }

    - (NSArray *)resources {
        return [self elementsWithName: @"resource"];
    }

    - (NSArray *)otherElements {
        return [self elementsWithName: @"##other"];
    }

@end