//
// Created by Tony Stone on 7/9/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectConfigurationAction.h"
#import "MGXMLElementDefinition.h"

@implementation MGConnectConfigurationAction

    static MGXMLElementDefinition * definition = nil;

    + (void)load {
        definition = [[MGXMLElementDefinition alloc]
                      initWithAttributeNames: @[
                                                @"id",
                                                @"type",
                                                @"name",
                                                @"method",
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

@end