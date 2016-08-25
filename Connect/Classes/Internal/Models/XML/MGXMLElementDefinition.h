//
// Created by Tony Stone on 7/11/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MGXMLElementDefinition : NSObject

    - (instancetype) initWithAttributeNames: (NSArray *) attributeNames elementNames: (NSArray *) elementNames;
    + (instancetype)definitionWithAttributeNames:(NSArray *)attributeNames elementNames:(NSArray *)elementNames;

    - (NSArray *) attributeNames;

    - (BOOL) allowAnyAttributes;
    - (BOOL) allowOtherAttributes;

    - (NSArray *) elementNames;
    - (NSUInteger) indexOfElementForName: (NSString *) name;


    - (BOOL) allowAnyElements;
    - (BOOL) allowOtherElements;

@end