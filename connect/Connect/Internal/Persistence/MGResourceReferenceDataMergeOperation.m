//
//  MGResourceReferenceDataMergeOperation.m
//  MGConnect
//
//  Created by Tony Stone on 4/16/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGResourceReferenceDataMergeOperation.h"

@implementation MGResourceReferenceDataMergeOperation

- (id) init {
    NSString * objectUniqueIDAttribute = @"resourceReference";
 
    NSArray * sourceSortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: objectUniqueIDAttribute ascending:YES]];
    NSArray * targetSortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: objectUniqueIDAttribute ascending:YES]];

    NSComparator comparator = ^NSComparisonResult (id obj1, id obj2) {
        
        return [[NSString stringWithFormat: @"%@/", [obj1 valueForKey: objectUniqueIDAttribute]] compare: [NSString stringWithFormat: @"%@/", [obj2 valueForKey: objectUniqueIDAttribute]]];
    };
    
    return [super initWithSourceSortDescriptors: sourceSortDescriptors targetSortDescriptors: targetSortDescriptors objectComparator: comparator objectUniqueIDAttribute: objectUniqueIDAttribute];
}

@end
