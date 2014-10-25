//
// Created by Tony Stone on 7/2/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGSQLitePersistentStore.h"
#import "MGConnect.h"
#include <Common/LogStream.h>

using mg::LogStream;

@implementation MGSQLitePersistentStore {

    }

    + (NSString *) storeType {
        return NSStringFromClass(self);
    }

    - (BOOL) loadMetadata: (NSError **) error {
    
        // Set the metadata up.
        NSString * uuid      = [[NSProcessInfo processInfo] globallyUniqueString];
        NSString * storeType = [[self class] storeType];
        
        [self setMetadata: @{NSStoreTypeKey: storeType,
                             NSStoreUUIDKey: uuid}];
        return YES;
    }

@end