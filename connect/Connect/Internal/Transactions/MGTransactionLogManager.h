//
//  MGTransactionLogManager.h
//  MGConnect
//
//  Created by Tony Stone on 4/17/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGTransactionLogRecord.h"

@class NSManagedObjectContext;

@interface MGTransactionLogManager : NSObject

/**
 Return a ManagedObject context which can be used to query the transactionLog from the current thread.
 */
- (NSManagedObjectContext *) transactionLogEditContext;

/**
 Log the changes currently in this managedObject context
 in a transaction.
 
 NOTE: This must be called before the Context is saved, otherwise 
       the change arrays inserted, updated, and deleted will be empty.
 */
- (MGTransactionID *) logTransactionForContextChanges: (NSManagedObjectContext *) aManagedObjectContext;

/**
 Clear all the transactionLogRecords for this transactioID
 */
- (void) removeTransaction: (MGTransactionID *) aTransactionID;

/**
 Return all the transaction log records for the transactionID
 */
- (NSArray *) transactionLogRecordsForTransaction: (MGTransactionID *) aTransactionID inContext: (NSManagedObjectContext *) aContext;

/**
 Return all the transaction log records for the entity
  */
- (NSArray *) transactionLogRecordsForEntity: (NSEntityDescription *) anEntityDescription inContext: (NSManagedObjectContext *) aContext;

@end

@class MGMetadataStore;

@interface MGTransactionLogManager (Initialization)

- (id) initWithMetadataStore: (MGMetadataStore *) aMetadataStore;

@end

