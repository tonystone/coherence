//
// Created by Tony Stone on 4/30/15.
//

#import <CoreData/CoreData.h>

@interface CCBackingStore : NSObject

    - (instancetype)initWithManagedObjectModel: (NSManagedObjectModel *) aModel;

    - (NSManagedObjectModel *) managedObjectModel;
    - (NSPersistentStoreCoordinator *) persistentStoreCoordinator;

    - (void) reset;
    - (void) clearAllData;

@end