//
// Created by Tony Stone on 9/4/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MGConnectModelMangler.h"
#import "MGConnectManagedObject.h"

@implementation MGConnectModelMangler {

    }

    + (void)configureModel:(NSManagedObjectModel *)aModel forConnectConfiguration:(NSURL *)aConnectConfiguration {

        NSString * managedObjectClassName        = NSStringFromClass([NSManagedObject class]);
        NSString * connectManagedObjectClassName = NSStringFromClass([MGConnectManagedObject class]);

        for (NSEntityDescription * entity in [aModel entities])  {
            if ([[entity managedObjectClassName] isEqualToString: managedObjectClassName]) {
                [entity setManagedObjectClassName: connectManagedObjectClassName];
            }
        }
    }

@end