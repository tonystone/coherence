//
//  MGPersistentStoreCoordinator.h
//  Connect
//
//  Created by Tony Stone on 5/12/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

/** @name Connect Persistent Store Types */
//@{

extern NSString * const MGSQLiteStoreType;
extern NSString * const MGInMemoryStoreType;

//@}


/** @interface MGPersistentStoreCoordinator
 
 Mobile Grid Connect is a runtime framework that manages local CoreData instances
 as a cache for remote resources.
 
 */
@interface MGPersistentStoreCoordinator : NSPersistentStoreCoordinator

    - (id) initWithManagedObjectModel: (NSManagedObjectModel *) aModel connectConfigurationURL: (NSURL *) configurationURL;

@end