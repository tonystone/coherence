//
// Created by Tony Stone on 7/2/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MGPersistentStore.h"

@interface MGInMemoryPersistentStore : NSIncrementalStore <MGPersistentStore>
@end