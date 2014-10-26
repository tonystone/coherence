//
// Created by Tony Stone on 7/9/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGWADLResponse.h"
#import "MGXMLElementDefinition.h"

@implementation MGWADLResponse

    static MGXMLElementDefinition * definition = nil;

    + (void)load {
        definition = [[MGXMLElementDefinition alloc]
                initWithAttributeNames: @[
                        @"status",
                        @"##other"
                ]
                          elementNames:@[
                                  @"doc",
                                  @"param",
                                  @"representation",
                                  @"##other"
                          ]
        ];
    }

    - (instancetype)initWithName:(NSString *)name qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI {
        self = [super initWithName:name qualifiedName:qualifiedName namespaceURI:namespaceURI definition: definition];

        return self;
    }

    - (NSUInteger)status {
        return [[[self attributes] objectForKey:@"status"] unsignedIntegerValue];
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

    - (NSArray *)representations {
        return [self elementsWithName: @"representation"];
    }

    - (NSArray *)otherElements {
        return [self elementsWithName: @"##other"];
    }

@end