//
// Created by Tony Stone on 5/22/15.
//

#import "NSManagedObjectModel+UniqueIdentity.h"


@implementation NSManagedObjectModel (UniqueIdentity)

    - (NSString *)uniqueIdentifier {
        //
        // Calculate the hash of the Models entityVersionHashes
        //
        NSUInteger hash        = 0;
        NSArray * entityHashes = [[self entityVersionHashesByName] allValues];

        if ([entityHashes count] > 0) {
            hash = [entityHashes[0] hash];

            for (int i = 1; i < [entityHashes count]; i++) {
                hash = hash * 31u + [entityHashes[i] hash];
            }
        }
        return [NSString stringWithFormat: @"%lu", (unsigned long) hash];
    }

@end