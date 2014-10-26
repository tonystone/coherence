//
// Created by Tony Stone on 10/25/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectConfigurationReader.h"
#import "MGWADLApplication.h"
#import "MGXMLReader.h"

@implementation MGConnectConfigurationReader

    + (MGWADLApplication *)wadlApplicationFromURL:(NSURL *)fileURL {
        MGWADLApplication * wadlApplication = nil;
        
        MGXMLDocument * xmlDocument = [MGXMLReader xmlDocumentFromURL: fileURL elementClassPrefixes: @[@"MGConnectWADL", @"MGWADL"]];
        
        if ([xmlDocument isKindOfClass: [MGWADLApplication class]]) {
            wadlApplication = (MGWADLApplication *) xmlDocument;
        }
        
        return wadlApplication;
    }


@end