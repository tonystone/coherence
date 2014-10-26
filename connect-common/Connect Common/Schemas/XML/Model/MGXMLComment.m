//
// Created by Tony Stone on 7/10/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGXMLComment.h"


@implementation MGXMLComment {
        NSString * text;
    }

    - (instancetype)initWithText:(NSString *)aText {
        self = [super init];
        if (self) {
            text = aText;
        }

        return self;
    }

    + (instancetype)commentWithText:(NSString *)aText {
        return [[self alloc] initWithText:aText];
    }

    - (NSString *)xmlString:(NSUInteger)level {
        return [[NSString alloc] initWithFormat: @"%@%@", [@"" stringByPaddingToLength: level withString:@"\t" startingAtIndex:0], [@"<!--" stringByAppendingFormat: @"%@-->", text]];;
    }

@end