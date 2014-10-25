//
//  MGLogReader.m
//  Connect
//
//  Created by Tony Stone on 5/7/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGLogReader.h"
#import <CoreData/CoreData.h>
#import "MGRuntimeException.h"
#import "MGManagedEntity.h"

@implementation MGLogReader {
    NSManagedObjectContext * logContext;
}

- (id) initWithManagedObjectContext:(NSManagedObjectContext *)aLogContext {
    
    if ((self = [super init])) {
        logContext = aLogContext;
    }
    return self;
}

- (NSArray *) transactionLogRecordsForManagedEntity: (MGManagedEntity *) managedEntity {
    
	NSFetchRequest * fetchRequest   = [[NSFetchRequest alloc] init];
    NSPredicate    * fetchPredicate = [NSPredicate predicateWithFormat: @"persistentStoreIdentifier == %@ AND entityName == %@", [managedEntity persistentStoreIdentifier], [[managedEntity entity] name]];

	[fetchRequest    setEntity: [NSEntityDescription entityForName: @"MGTransactionLogRecord" inManagedObjectContext: logContext]];
    [fetchRequest setPredicate: fetchPredicate];
	
    NSError * error = nil;
    
    NSArray * fetchResults = [logContext executeFetchRequest: fetchRequest error: &error];
    
    if (error) {
        @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [error localizedFailureReason] userInfo: @{@"error": error}];
    }
    
    return fetchResults;
}

@end
