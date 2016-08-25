//
// Created by Tony Stone on 7/9/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGWADLResource.h"
#import "MGXMLElementDefinition.h"

@implementation MGWADLResource

    static MGXMLElementDefinition * definition = nil;

    + (void)load {
        definition = [[MGXMLElementDefinition alloc]
                initWithAttributeNames: @[
                        @"id",
                        @"type",
                        @"queryType",
                        @"path",
                        @"##other"
                ]
                          elementNames:@[
                                  @"doc",
                                  @"param",
                                  @"method",
                                  @"resource",
                                  @"##other"
                          ]
        ];
    }

    - (instancetype)initWithName:(NSString *)name qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI {
        self = [super initWithName:name qualifiedName:qualifiedName namespaceURI:namespaceURI definition: definition];

        return self;
    }

    - (NSString *)eid {
        return [[self attributes] objectForKey:@"id"];
    }

    - (NSString *)type {
        return [[self attributes] objectForKey:@"type"];
    }

    - (NSString *)queryType {
        NSString * queryType = [[self attributes] objectForKey:@"queryType"];

        if (!queryType)
            queryType = @"application/x-www-form-urlencoded"; // Default

        return queryType;
    }

    - (NSString *)path {
        return [[self attributes] objectForKey:@"path"];
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

    - (NSArray *)methods {
        return [self elementsWithName: @"method"];
    }

    - (NSArray *)resources {
        return [self elementsWithName: @"resource"];
    }

    - (NSArray *)otherElements {
        return [self elementsWithName: @"##other"];
    }

@end