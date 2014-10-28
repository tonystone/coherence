//
// Created by Tony Stone on 10/25/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGConfigurationReader.h"
#import "MGWADLApplication.h"
#import "MGXMLReader.h"

#import <ConnectCommon/ConnectCommon.h>

@implementation MGConfigurationReader

    + (MGWADLApplication *)connectConfigurationFromURL:(NSURL *)fileURL {
        MGWADLApplication * wadlApplication = nil;
        
        MGXMLDocument * xmlDocument = [MGXMLReader xmlDocumentFromURL: fileURL elementClassPrefixes: @[@"MGConnectWADL", @"MGWADL"]];
        
        //
        // RUn the resolver on the document to resolve local links.
        //
        
        // XML document should only have 1 element of type MGWADLApplication
        NSArray * applications = [[xmlDocument elements] filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject isKindOfClass: [MGWADLApplication class]];
        }]];
        
        if ([applications count] == 1) {
            wadlApplication = (MGWADLApplication *) [applications objectAtIndex: 0];
        } else {
            LogError(@"The connect confuration file supplied is invalid, there can only be one application specified.");
        }
        
        return wadlApplication;
    }


@end