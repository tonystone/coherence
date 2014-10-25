//
//  MGLogWriter.h
//  Connect
//
//  Created by Tony Stone on 5/7/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGTransactionLogRecord.h"

@class NSManagedObjectContext;
@class MGMetadataManager;
@class MGConnectManagedObjectContext;

@interface MGLogWriter : NSObject

- (id) initWithManagedObjectContext:(NSManagedObjectContext *)aLogContext metadataManager: (MGMetadataManager *) aMetadataManager;

- (MGTransactionID *) logTransactionForContextChanges: (MGConnectManagedObjectContext *) aChangeContext;
- (void) removeTransaction: (MGTransactionID *) aTransactionID;

@end
