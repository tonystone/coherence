//
//  MGLoggedManagedObjectContext.h
//  MGConnect
//
//  Created by Tony Stone on 3/28/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MGDataStoreManager;
@class MGTransactionLogManager;

@interface MGLoggedManagedObjectContext : NSManagedObjectContext

- (id) initWithDataStoreManager: (MGDataStoreManager *) aDataStoreManager notificationSelector: (SEL) aSelector transactionLogManager: (MGTransactionLogManager *) aTransactionLogManager;

- (MGTransactionLogManager *) transactionLogManager;

- (BOOL) save:(NSError *__autoreleasing *)error logChanges: (BOOL) logChanges;

@end
