//
// Created by Tony Stone on 7/9/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGWADLMethod.h"
#import "MGXMLElementDefinition.h"


@implementation MGWADLMethod

    static MGXMLElementDefinition * definition = nil;

    + (void)load {
        definition = [[MGXMLElementDefinition alloc]
                initWithAttributeNames: @[
                        @"id",
                        @"name",
                        @"href",
                        @"##other"
                ]
                          elementNames:@[
                                  @"doc",
                                  @"request",
                                  @"response",
                                  @"##other"
                          ]
        ];
    }

    - (instancetype)initWithName:(NSString *)name qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI {
        self = [super initWithName:name qualifiedName:qualifiedName namespaceURI:namespaceURI definition: definition];

        return self;
    }

    - (NSString *)eid {
        return [[self attributes] objectForKey: @"id"];
    }

    - (NSString *)name {
        return [[self attributes] objectForKey: @"name"];
    }

    - (NSString *)href {
        return [[self attributes] objectForKey: @"href"];
    }

    - (NSDictionary *)otherAttributes {
        return [super otherAttributes];
    }

    - (NSArray *)docs {
        return [self elementsWithName: @"doc"];
    }

    - (MGWADLRequest *)request {
        return [self elementsWithName: @"request"];
    }

    - (NSArray *)responses {
        return [self elementsWithName: @"response"];
    }

    - (NSArray *)otherElements {
        return [self elementsWithName: @"##other"];
    }

@end