//
//  MGDataMergeOperation.h
//  MGConnect
//
//  Created by Tony Stone on 4/16/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSEntityDescription;
@class NSPredicate;
@class MGLoggedManagedObjectContext;

@interface MGDataMergeOperation : NSObject

- (BOOL) mergeObjects: (NSArray *) sourceObjects entity: (NSEntityDescription *) anEntity subFilter: (NSPredicate *) aMergeFilter context:(MGLoggedManagedObjectContext *) mergeContext error:(NSError **)error;

@end


@interface MGDataMergeOperation (Initialization)

- (id) initWithSourceSortDescriptors: (NSArray *) theSourceSortDescriptors targetSortDescriptors: (NSArray *) theTargetSortDescriptors objectComparator: (NSComparator) aComparator objectUniqueIDAttribute: (NSString *) anObjectUniqueIDAttribute;

@end