//
//  MGCacheManager.h
//  MGConnect
//
//  Created by Tony Stone on 3/29/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGEntityAction.h"

@class NSManagedObjectModel;

@interface MGDataStoreManager : NSObject

- (NSManagedObjectContext *) mainThreadManagedObjectContext;
- (NSManagedObjectContext *) editManagedObjectContext;

- (void) open: (NSDictionary *) options ;
- (void) close;

- (void) start;
- (void) stop;

- (void) setOffline;
- (void) setOnline;

- (void) executeAction: (MGEntityAction *) anAction waitUntilDone: (BOOL) wait;

@end

@interface MGDataStoreManager (Initialization)

- (id) initWithName: (NSString *) aDataStoreName managedObjectModel: (NSManagedObjectModel *) aManagedObjectModel;

@end


