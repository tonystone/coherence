//
// Created by Tony Stone on 9/4/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSManagedObjectModel.h>

@interface MGConnectModelMangler : NSObject

    + (void) configureModel: (NSManagedObjectModel *) aModel forConnectConfiguration: (NSURL *) aConnectConfiguration;

@end