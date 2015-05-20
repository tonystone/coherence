//
// Created by Tony Stone on 4/30/15.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CCBackingStore;
@class CCWriteAheadLog;

@interface CCManagedObjectContext : NSManagedObjectContext

    - (id)initWithBackingStore:(CCBackingStore *)aBackingStore writeAheadLog:(CCWriteAheadLog *) aWriteAheadLog;
    - (id)initWithBackingStore:(CCBackingStore *)aBackingStore writeAheadLog:(CCWriteAheadLog *) aWriteAheadLog parent: (CCManagedObjectContext *) aParent;

    - (BOOL)save:(NSError **)error logChanges: (BOOL)logChanges;

    - (void) registerListener: (CCManagedObjectContext *) listener;
    - (void) unregisterListener: (CCManagedObjectContext *) listener;

@end