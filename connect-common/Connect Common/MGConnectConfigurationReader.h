//
// Created by Tony Stone on 10/25/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MGWADLApplication;

@interface MGConnectConfigurationReader : NSObject
    + (MGWADLApplication *) wadlApplicationFromURL: (NSURL *) fileURL;
@end