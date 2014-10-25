//
//  Resource+Extensions.m
//  CloudBase
//
//  Created by Tony Stone on 11/5/11.
//  Copyright (c) 2011 Mobile Grid, Inc. All rights reserved.
//

#import "Resource+Extensions.h"

@implementation Resource (Extensions)
- (NSString *) resourceId {
    return [self.resourceReference lastPathComponent];
}
- (NSDictionary *) dictionaryWithValuesAndKeys {
    return [self dictionaryWithValuesForKeys: [[[self entity] attributesByName] allKeys]];
}
- (NSArray *) tags {
    return [[self valueForKey: @"fetchTags"] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        // By using valueForKey, we're forcing the faulted object to be read from disk
        return [[obj1 valueForKey: @"position"] compare: [obj2 valueForKey: @"position"]];
    }];
}
@end
