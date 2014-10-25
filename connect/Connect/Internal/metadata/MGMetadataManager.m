//
//  MGMetadataManager.m
//  Connect
//
//  Created by Tony Stone on 5/2/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGMetadataManager.h"

#import "MGTraceLog.h"
#import "MGMetadataBackingStore.h"
#import "MGPassthroughManagedObjectContext.h"
#import "MGLogWriter.h"
#import "MGLogReader.h"

@implementation MGMetadataManager {
    MGMetadataBackingStore * backingStore;
    NSUInteger               nextSequenceNumber;
}

static MGMetadataManager * sharedManager;

+ (void) initialize {
    
    LogInfo(@"%@ Initializing...", NSStringFromClass(self));
    
    sharedManager = [[self alloc] init];
    
    LogInfo(@"%@ Initialized", NSStringFromClass(self));
}

- (id) init {

    if (sharedManager) {
        //
        // Note, this is a singleten
        //       return the sharedManager
        //       instance if already initialize
        //
        self = sharedManager;
        
    } else if ((self = [super init])) {
        backingStore = [[MGMetadataBackingStore alloc] init];
        
        //
        // Force it to load the stack now
        //
        (void) [backingStore persistentStoreCoordinator];
        
        [self initializeSequenceNumberGenerator];
    }
    return self;
}

+ (MGMetadataManager *) sharedManager {
    return sharedManager;
}

- (void) initializeSequenceNumberGenerator {
    @synchronized (self) {
        
#warning This should be gotten from a table stored in the DB so we have continues sequence numbering
        //
        // We need to find the last log entry and get it's
        // sequenceNumber value to calculate the next number
        // in the database.
        //
        MGPassthroughManagedObjectContext * context = [[MGPassthroughManagedObjectContext alloc] init];
        
        [context setPersistentStoreCoordinator: [backingStore persistentStoreCoordinator]];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MGTransactionLogRecord" inManagedObjectContext:context];
        [request setEntity:entity];
        
        // Specify that the request should return dictionaries.
        [request setResultType:NSDictionaryResultType];
        
        // Create an expression for the key path.
        NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"sequenceNumber"];
        
        // Create an expression to represent the maximum value at the key path 'creationDate'
        NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
        
        // Create an expression description using the maxExpression and returning a date.
        NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
        
        // The name is the key that will be used in the dictionary for the return value.
        [expressionDescription setName:@"maxSequenceNumber"];
        [expressionDescription setExpression:maxExpression];
        [expressionDescription setExpressionResultType:NSInteger32AttributeType];
        
        // Set the request's properties to fetch just the property represented by the expressions.
        [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
        
        // Execute the fetch.
        NSError *error = nil;
        
        NSArray *objects = [context executeFetchRequest:request error:&error];
        if (objects == nil) {
            // Handle the error.
        }
        else {
            if ([objects count] > 0) {
                nextSequenceNumber = [[[objects objectAtIndex:0] valueForKey:@"maxSequenceNumber"] unsignedIntegerValue] + 1;
            } else {
                nextSequenceNumber = 1;
            }
        }
    }
}

- (NSUInteger) nextSequenceNumberBlock: (NSUInteger) size {
    @synchronized (self) {
        NSUInteger sequenceNumberBlockStart = nextSequenceNumber;
        
        nextSequenceNumber = nextSequenceNumber + size;
        
        return sequenceNumberBlockStart;
    }
}

- (MGLogWriter *) logWriter {
    MGPassthroughManagedObjectContext * context = [[MGPassthroughManagedObjectContext alloc] init];
    
    [context setPersistentStoreCoordinator: [backingStore persistentStoreCoordinator]];
    
    return [[MGLogWriter alloc] initWithManagedObjectContext: context metadataManager: self];
}

- (MGLogReader *) logReader {
    MGPassthroughManagedObjectContext * context = [[MGPassthroughManagedObjectContext alloc] init];
    
    [context setPersistentStoreCoordinator: [backingStore persistentStoreCoordinator]];
    
    return [[MGLogReader alloc] initWithManagedObjectContext: context];
}

@end
