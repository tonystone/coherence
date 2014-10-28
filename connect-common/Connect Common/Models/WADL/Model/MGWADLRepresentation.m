//
// Created by Tony Stone on 7/9/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGWADLRepresentation.h"
#import "MGXMLElementDefinition.h"

@implementation MGWADLRepresentation

    static MGXMLElementDefinition * definition = nil;

    + (void)load {
        definition = [[MGXMLElementDefinition alloc]
                initWithAttributeNames: @[
                        @"id",
                        @"element",
                        @"mediaType",
                        @"href",
                        @"profile",
                        @"##other"
                ]
                          elementNames:@[
                                  @"doc",
                                  @"param",
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

    - (NSString *)element {
        return [[self attributes] objectForKey: @"element"];
    }

    - (NSString *)mediaType {
        return [[self attributes] objectForKey: @"mediaType"];
    }

    - (NSString *)href {
        return [[self attributes] objectForKey: @"href"];
    }

    - (NSString *)profile {
        return [[self attributes] objectForKey: @"profile"];
    }

    - (NSDictionary *)otherAttributes {
        return [super otherAttributes];
    }

    - (NSArray *)docs {
        return [self elementsWithName: @"doc"];
    }

    - (NSArray *)params {
        return [self elementsWithName: @"param"];
    }

    - (NSArray *)otherElements {
        return [self elementsWithName: @"##other"];
    }

@end