//
// Created by Tony Stone on 4/30/15.
//

#import <CoreData/CoreData.h>

@interface CCBackingStore : NSObject

    - (instancetype)initWithIdentifier: (NSString *) anIdentifier managedObjectModel:(NSManagedObjectModel *) aModel;

    - (NSManagedObjectModel *) managedObjectModel;
    - (NSPersistentStoreCoordinator *) persistentStoreCoordinator;

    - (void) reset;
    - (void) clearAllData;

@end