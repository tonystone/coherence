//
// Created by Tony Stone on 7/9/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGWADLApplication.h"
#import "MGWADL.h"
#import "MGXMLElementDefinition.h"



@implementation MGWADLApplication {
    }

    static MGXMLElementDefinition * definition = nil;

    + (void)load {
        definition = [[MGXMLElementDefinition alloc]
                initWithAttributeNames: @[]
                          elementNames:@[
                                  @"doc",
                                  @"grammars",
                                  @"resources",
                                  @"resource_type",
                                  @"method",
                                  @"representation",
                                  @"param",
                                  @"##other"]];
    }

    - (instancetype)initWithName:(NSString *)name qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI {
        self = [super initWithName:name qualifiedName:qualifiedName namespaceURI:namespaceURI definition: definition];

        return self;
    }

    - (NSArray *)docs {
        return [self elementsWithName: @"doc"];
    }

    - (NSArray *)grammars {
        return [self elementsWithName: @"grammars"];
    }

    - (NSArray *)resources {
        return [self elementsWithName: @"resources"];
    }

    - (NSArray *)resourceTypes {
        return [self elementsWithName: @"resource_type"];
    }

    - (NSArray *)methods {
        return [self elementsWithName: @"method"];
    }

    - (NSArray *)representations {
        return [self elementsWithName: @"representation"];
    }

    - (NSArray *)params {
        return [self elementsWithName: @"param"];
    }

    - (NSArray *)otherElements {
        return [self elementsWithName: @"##other"];
    }

@end