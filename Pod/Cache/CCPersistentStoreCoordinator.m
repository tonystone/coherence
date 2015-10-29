/**
 *   CCPersistentStoreCoordinator.m
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
 *   Created by Tony Stone on 5/21/15.
 */
#import "CCPersistentStoreCoordinator.h"
#import "CCWriteAheadLog.h"
#import "CCMetaModel.h"
#import "NSManagedObjectModel+UniqueIdentity.h"
#import <TraceLog/TraceLog.h>

static const unsigned int kDefaultLogTransactions = TRUE;

@implementation CCPersistentStoreCoordinator {
        CCWriteAheadLog * _writeAheadLog;

        struct  {
            unsigned int _logTransactions:1;
            unsigned int _reservedFlags:31;
        } _flags;
    }

    - (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)model {
        NSParameterAssert(model != nil);

        LogInfo(@"Initializing '%@' instance...", NSStringFromClass([self class]));

        self = [super initWithManagedObjectModel:model];
        if (self) {
            //
            // Initialize flags to defaults first
            //
            _flags._logTransactions = kDefaultLogTransactions;
            
            //
            // Now create our write ahead logger
            //
            NSString * cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSURL * metadataURL = [NSURL fileURLWithPath: [cachesPath stringByAppendingFormat: @"/Meta%@.bin", [model uniqueIdentifier]]];

            _writeAheadLog = [[CCWriteAheadLog alloc] initWithURL: metadataURL];
            
            LogInfo(@"'%@' instance initialized.", NSStringFromClass([self class]));
        }
        return self;
    }

    - (NSPersistentStore *)addPersistentStoreWithType:(NSString *)storeType configuration:(NSString *)configuration URL:(NSURL *)storeURL options:(NSDictionary *)options error:(NSError **)error {
        LogInfo(@"Attaching persistent store for type: %@ at path: %@...", storeType, storeURL);
        
        NSError * internalError = nil;
        
        NSPersistentStore * persistentStore = [super addPersistentStoreWithType:storeType configuration:configuration URL:storeURL options:options error:error];
        
        if (error) {
            *error = internalError;
        }
        
#ifdef DEBUG
        if (persistentStore) {
            LogInfo(@"Persistent Store attached.");
        } else {
            LogError(@"Failed to attach persistent store: %@", [internalError localizedDescription]);
        }
#endif
        
        return persistentStore;
    }

    - (BOOL)removePersistentStore:(NSPersistentStore *)store error:(NSError **)error {
        LogInfo(@"Removing persistent store for type: %@ at path: %@...", [store type], [store URL]);
        
        NSError * internalError = nil;
        
        BOOL success = [super removePersistentStore:store error: &internalError];
        
        if (error) {
            *error = internalError;
        }
        
#ifdef DEBUG
        if (success) {
            LogInfo(@"Persistent Store removed.");
        } else {
            LogError(@"Failed to remove persistent store: %@", [internalError localizedDescription]);
        }
#endif
        return success;
    }

    - (id)executeRequest:(NSPersistentStoreRequest *)request withContext:(NSManagedObjectContext *)context error:(NSError **)error {

        switch ([request requestType]) {

            case NSFetchRequestType:
                return [super executeRequest:request withContext:context error:error];

            case NSSaveRequestType:
            case NSBatchUpdateRequestType:
            {
                if (_writeAheadLog) {

                    //
                    // Obtain permanent IDs for all inserted objects
                    //
                    if (![context obtainPermanentIDsForObjects: [[context insertedObjects] allObjects] error: error]) {
                        return nil;
                    }

                    //
                    // Log the changes from the context in a transaction
                    //
                    CCTransactionID * transactionID = [_writeAheadLog logTransactionForContextChanges: context];

                    //
                    // Save the main context
                    //
                    NSError * saveError = nil;

                    id results = [super executeRequest:request withContext:context error: &saveError];
                    if (saveError) {
                        [_writeAheadLog removeTransaction: transactionID];

                        if (error) {
                            *error = saveError;
                        }
                    }
                    return results;
                }
            }
        }
        return nil;
    }


@end