//
// Created by Tony Stone on 7/9/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGWADLDoc.h"
#import "MGXMLElementDefinition.h"

@implementation MGWADLDoc

    static MGXMLElementDefinition * definition = nil;

    + (void)load {
        definition = [[MGXMLElementDefinition alloc]
                initWithAttributeNames: @[
                        @"title",
                        @"ref",
                        @"text",
                        @"##other"
                ]
                          elementNames:@[
                                  @"##other"
                          ]
        ];
    }

    - (instancetype)initWithName:(NSString *)name qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI {
        self = [super initWithName:name qualifiedName:qualifiedName namespaceURI:namespaceURI definition: definition];

        return self;
    }

    - (NSString *)title {
        return [[self attributes] objectForKey: @"title"];
    }

    - (NSString *)ref {
        return [[self attributes] objectForKey: @"ref"];
    }

    - (NSString *)text {
        return [[self attributes] objectForKey: @"text"];
    }

    - (NSDictionary *)otherAttributes {
        return [super otherAttributes];
    }

    - (NSArray *)otherElements {
        return [self elementsWithName: @"##other"];
    }


@end