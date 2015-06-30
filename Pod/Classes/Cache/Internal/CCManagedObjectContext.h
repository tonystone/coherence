//
// Created by Tony Stone on 4/30/15.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CCWriteAheadLog;

@interface CCManagedObjectContext : NSManagedObjectContext

    - (instancetype)initWithConcurrencyType:(NSManagedObjectContextConcurrencyType)ct parent: (CCManagedObjectContext *) aParent;

    - (void) registerListener: (CCManagedObjectContext *) listener;
    - (void) unregisterListener: (CCManagedObjectContext *) listener;

@end