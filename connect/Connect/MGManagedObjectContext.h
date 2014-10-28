//
//  MGManagedObjectContext.h
//  Connect
//
//  Created by Tony Stone on 5/8/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface MGManagedObjectContext : NSManagedObjectContext

- (id) init;
- (id) initSynchronized: (BOOL) isSynchronized;

- (id) initWithConcurrencyType:(NSManagedObjectContextConcurrencyType)ct;
- (id) initWithConcurrencyType:(NSManagedObjectContextConcurrencyType)ct synchronized: (BOOL) synchronized;

    - (NSString *) description;

    - (BOOL) isEqual: (id) other;

    - (BOOL) isEqualToContext: (MGManagedObjectContext *) context;

    - (NSUInteger) hash;

@end
