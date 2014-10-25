//
// Created by Tony Stone on 7/10/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGXMLCDATA.h"


@implementation MGXMLCDATA {
        NSData * CDataBlock;
    }

    - (instancetype)initWithData:(NSData *)aCDATABlock {
        self = [super init];
        if (self) {
            CDataBlock = aCDATABlock;
        }

        return self;
    }

    + (instancetype)cdataWithData:(NSData *)aCDATABlock {
        return [[self alloc] initWithData:aCDATABlock];
    }

    - (NSString *)xmlString:(NSUInteger)level {
        return [[NSString alloc] initWithFormat: @"%@%@", [@"" stringByPaddingToLength: level withString:@"\t" startingAtIndex:0], [@"<!CDATA[" stringByAppendingFormat: @"%@]]>", CDataBlock]];;
    }

@end