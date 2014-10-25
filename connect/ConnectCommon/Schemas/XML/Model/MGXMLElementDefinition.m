//
// Created by Tony Stone on 7/11/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGXMLElementDefinition.h"


@implementation MGXMLElementDefinition {
        NSArray * _attributeNames;
        NSArray * _elementNames;

        struct flags {
            unsigned int allowOtherAttributes:1;
            unsigned int allowAnyAttributes:1;
            unsigned int allowOtherElements:1;
            unsigned int allowAnyElements:1;
            unsigned int reserved:28;
        } _flags;
    }

    - (instancetype)initWithAttributeNames:(NSArray *)attributeNames elementNames:(NSArray *)elementNames {
        self = [super init];
        if (self) {
            _attributeNames = [attributeNames copy];
            _elementNames   = [elementNames copy];

            _flags.allowOtherAttributes = (unsigned int) [_attributeNames containsObject: @"##other"];
            _flags.allowAnyAttributes   = (unsigned int) [_attributeNames containsObject: @"##any"];

            _flags.allowOtherElements = (unsigned int) [_elementNames containsObject: @"##other"];
            _flags.allowAnyElements   = (unsigned int) [_elementNames containsObject: @"##any"];
        }

        return self;
    }

    + (instancetype) definitionWithAttributeNames:(NSArray *)attributeNames elementNames:(NSArray *)elementNames {
        return [[self alloc] initWithAttributeNames:attributeNames elementNames:elementNames];
    }

    - (NSArray *) attributeNames {
        return _attributeNames;
    }

    - (BOOL) allowAnyAttributes {
        return (BOOL) _flags.allowAnyAttributes;
    }

    - (BOOL) allowOtherAttributes {
        return (BOOL) _flags.allowOtherAttributes;
    }

    - (NSArray *) elementNames {
        return _elementNames;
    }

    - (NSUInteger)indexOfElementForName:(NSString *)name {
        NSUInteger index = 0;
        for (NSString * elementName in _elementNames) {
            if ([elementName isEqualToString: name]) {
                return index;
            }
            index++;
        }
        return NSNotFound;
    }


    - (BOOL) allowAnyElements {
        return (BOOL) _flags.allowAnyElements;
    }

    - (BOOL) allowOtherElements {
        return (BOOL) _flags.allowOtherElements;
    }

@end