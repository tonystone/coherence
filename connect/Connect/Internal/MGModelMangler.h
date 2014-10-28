//
// Created by Tony Stone on 9/4/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSManagedObjectModel.h>

@class MGWADLApplication;

@interface MGModelMangler : NSObject

    + (void) configureModel: (NSManagedObjectModel *) aModel forConnectConfiguration: (MGWADLApplication *) wadlApplication;

@end