//
//  MGMetadataBackingStore.h
//  Connect
//
//  Created by Tony Stone on 5/2/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@interface MGMetadataBackingStore : NSObject

- (void) reset;
- (void) clearAllData;

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator;

@end
