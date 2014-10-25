//
// Created by Tony Stone on 7/9/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGWADLParam.h"
#import "MGXMLElementDefinition.h"

@implementation MGWADLParam

    static MGXMLElementDefinition * definition = nil;

    + (void)load {
        definition = [[MGXMLElementDefinition alloc]
                initWithAttributeNames: @[
                        @"href",
                        @"name",
                        @"style",
                        @"id",
                        @"type",
                        @"default",
                        @"required",
                        @"repeating",
                        @"fixed",
                        @"path",
                        @"##other"
                ]
                          elementNames:@[
                                  @"doc",
                                  @"option",
                                  @"link",
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

    - (NSString *)href {
        return [[self attributes] objectForKey: @"href"];
    }

    - (NSString *)name {
        return [[self attributes] objectForKey: @"name"];
    }

    - (NSString *)style {
        return [[self attributes] objectForKey: @"style"];
    }

    - (NSString *)type {
        return [[self attributes] objectForKey: @"type"];
    }

    - (NSString *)defaultValue {
        return [[self attributes] objectForKey: @"default"];
    }

    - (BOOL)required {
        return [[[self attributes] objectForKey:@"required"] boolValue];
    }

    - (BOOL)repeating {
        return [[[self attributes] objectForKey:@"repeating"] boolValue];
    }

    - (NSString *)fixed {
        return [[self attributes] objectForKey: @"fixed"];
    }

    - (NSString *)path {
        return [[self attributes] objectForKey: @"path"];
    }

    - (NSDictionary *)otherAttributes {
        return [super otherAttributes];
    }

    - (NSArray *)docs {
        return [self elementsWithName: @"doc"];
    }

    - (NSArray *)options {
        return [self elementsWithName: @"option"];
    }

    - (NSArray *)links {
        return [self elementsWithName: @"link"];
    }

    - (NSArray *)otherElements {
        return [self elementsWithName: @"##other"];
    }


@end