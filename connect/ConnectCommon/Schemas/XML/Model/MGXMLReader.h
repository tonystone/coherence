//
// Created by Tony Stone on 7/9/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGXMLDocument.h"

@interface MGXMLReader : NSObject

    + (MGXMLDocument *) xmlDocumentFromData:(NSData *) data;
    + (MGXMLDocument *)xmlDocumentFromData:(NSData *) data elementClassPrefixes: (NSArray *) prefixes;
    + (MGXMLDocument *) xmlDocumentFromURL: (NSURL *) fileURL;
    + (MGXMLDocument *)xmlDocumentFromURL:(NSURL *) fileURL elementClassPrefixes: (NSArray *) prefixes;

@end