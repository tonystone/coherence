//
//  MGLogReader.h
//  Connect
//
//  Created by Tony Stone on 5/7/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;
@class MGManagedEntity;

@interface MGLogReader : NSObject

- (id) initWithManagedObjectContext: (NSManagedObjectContext *) aLogContext;

- (NSArray *) transactionLogRecordsForManagedEntity: (MGManagedEntity *) managedEntity;

@end
