//
//  MGBackingStoreInitializer.h
//  CloudScope
//
//  Created by Tony Stone on 2/20/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MGBackingStoreInitializer <NSObject>
@required
+ (void) loadDataInContext: (NSManagedObjectContext *) loadContext forConfiguration: (NSString *) configuration; 
@optional
+ (void)   loadGlobalPersistentDataInContext: (NSManagedObjectContext *) loadContext; 
+ (void) loadInstancePersistentDataInContext: (NSManagedObjectContext *) loadContext; 
+ (void)  loadInstanceTransientDataInContext: (NSManagedObjectContext *) loadContext; 
@end
