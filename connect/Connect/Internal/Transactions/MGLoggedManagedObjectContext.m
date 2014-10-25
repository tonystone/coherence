//
//  MGLoggedManagedObjectContext.m
//  MGConnect
//
//  Created by Tony Stone on 3/28/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGLoggedManagedObjectContext.h"
#import "MGConnect+PrivateSettings.h"
#import "MGTransactionLogManager.h"
#import "MGTraceLog.h"

@implementation MGLoggedManagedObjectContext {
    MGDataStoreManager __unsafe_unretained * dataStoreManager;
    MGTransactionLogManager                * transactionLogManager;
}

- (id) initWithDataStoreManager: (MGDataStoreManager *) aDataStoreManager notificationSelector: (SEL) aSelector transactionLogManager: (MGTransactionLogManager *) aTransactionLogManager {
    
    NSParameterAssert(aDataStoreManager != nil);
    NSParameterAssert(aSelector != nil);
    NSParameterAssert(aTransactionLogManager != nil);
    
    LogTrace(4, @"Initializing <%@ : %p> instance for dataStore: %p transactionLog: %p...", NSStringFromClass([self class]), self, aDataStoreManager, aTransactionLogManager);
    
    if ((self = [super init])) {
        dataStoreManager      = aDataStoreManager;
        transactionLogManager = aTransactionLogManager;
        
        [[NSNotificationCenter defaultCenter] addObserver: dataStoreManager selector: aSelector name: NSManagedObjectContextDidSaveNotification object: self];
    }
    
    LogTrace(4, @"<%@ : %p> initialized", NSStringFromClass([self class]), self);
    
    return  self;
}

- (void) dealloc {
    if (dataStoreManager) {
        [[NSNotificationCenter defaultCenter] removeObserver: dataStoreManager name: NSManagedObjectContextDidSaveNotification object: self];
    }
}

- (MGTransactionLogManager *) transactionLogManager {
    return transactionLogManager;
}

- (BOOL) save:(NSError *__autoreleasing *)error {
    //
    // Obtain permanent IDs for all inserted objects
    //
    if (![self obtainPermanentIDsForObjects: [[self insertedObjects] allObjects] error: error]) {
        return NO;
    }

    //
    // Log the changes from the context in a transaction
    //
    MGTransactionID * transactionID = [transactionLogManager logTransactionForContextChanges: self];
    
    //
    // Save the main context
    //
    if (![super save: error]) {
        [transactionLogManager removeTransaction: transactionID];
        
        // @throw
    }
    return YES;
}

- (BOOL) save:(NSError *__autoreleasing *)error logChanges: (BOOL) logChanges {
    
    if (logChanges) {
        return [self save: error];
    } else {
        return [super save: error];
    }
}

- (NSArray *) executeFetchRequest:(NSFetchRequest *)request error:(NSError *__autoreleasing *)error {
    NSEntityDescription * entity = [request entity];
    
    if (!entity) {
        @throw [NSException exceptionWithName: @"FetchRequest Exception" reason: @"NSFetchRequest without an NSEntityDescription" userInfo: nil];
    }
    
    if ([entity managed]) {
        // callback data store
    }
    
    return [super executeFetchRequest: request error: error];
}

- (void) refreshObject:(NSManagedObject *)object mergeChanges:(BOOL)mergeChanges {
    
}

@end
