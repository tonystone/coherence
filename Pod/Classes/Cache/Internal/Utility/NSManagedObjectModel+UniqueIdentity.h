//
// Created by Tony Stone on 5/22/15.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NSManagedObjectModel (UniqueIdentity)
    - (NSString *)uniqueIdentifier;
@end