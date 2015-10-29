/**
 *   CCWriteAheadLog.h
 *
 *   Copyright 2015 The Climate Corporation
 *   Copyright 2015 Tony Stone
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *
 *   Created by Tony Stone on 4/30/15.
 */
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