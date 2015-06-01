//
// Created by Tony Stone on 4/30/15.
//

#import <Foundation/Foundation.h>
#import "CCMetaLogEntry.h"


@interface CCWriteAheadLog : NSObject

    - (id) initWithURL: (NSURL *) url;

    /**
        Log the changes currently in this managedObject context
        in a transaction.

        NOTE: This must be called before the Context is saved, otherwise
        the change arrays inserted, updated, and deleted will be empty.
    */
    - (CCTransactionID *) logTransactionForContextChanges: (NSManagedObjectContext *) aManagedObjectContext;

    /**
        Clear all the transactionLogRecords for this transactionID
    */
    - (void) removeTransaction: (CCTransactionID *) aTransactionID;

    /**
        Return all the transaction log records for the transactionID
    */
    - (NSArray *)transactionLogEntriesForTransaction:(CCTransactionID *)aTransactionID inContext: (NSManagedObjectContext *) aContext;

    /**
        Return all the transaction log records for the entity
    */
    - (NSArray *) transactionLogRecordsForEntity: (NSEntityDescription *) anEntityDescription inContext: (NSManagedObjectContext *) aContext;


@end