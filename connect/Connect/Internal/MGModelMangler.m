//
// Created by Tony Stone on 9/4/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MGModelMangler.h"
#import "MGManagedObject.h"
#import <ConnectCommon/ConnectCommon.h>

@implementation MGModelMangler {

    }

    + (void)configureModel:(NSManagedObjectModel *)aModel forConnectConfiguration:(MGWADLApplication *) wadlApplication {

        NSString * managedObjectClassName        = NSStringFromClass([NSManagedObject class]);
        NSString * connectManagedObjectClassName = NSStringFromClass([MGManagedObject class]);

        for (NSEntityDescription * entity in [aModel entities])  {
            if ([[entity managedObjectClassName] isEqualToString: managedObjectClassName]) {
                [entity setManagedObjectClassName: connectManagedObjectClassName];
            }
        }
    }

@end