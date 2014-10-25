//
//  MGConnectPersistentStoreCoordinator.h
//  Connect
//
//  Created by Tony Stone on 5/12/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface MGConnectPersistentStoreCoordinator : NSPersistentStoreCoordinator

    - (id) initWithManagedObjectModel: (NSManagedObjectModel *) aModel connectConfiguration: (NSString *) configurationFileName;

@end