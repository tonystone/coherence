//
// Created by Tony Stone on 7/10/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGXMLDocument.h"
#import "MGXMLElement.h"

@implementation MGXMLDocument {

    }

    - (NSArray *) elements {
        return [[self children] filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject isKindOfClass: [MGXMLElement class]];
        }]];
    }

    - (NSString *)xmlString {
        return [self xmlString: 0];
    }

    - (NSString *)xmlString:(NSUInteger)level {
        NSMutableString * xmlString = [[NSMutableString alloc] initWithString: @"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"];

        for (MGXMLNode * node in [self children]) {
            [xmlString appendFormat: @"\r\n%@", [node xmlString: level]];
        }
        return xmlString;
    }

@end