//
//  MGDataMergeOperation.h
//  MGConnect
//
//  Created by Tony Stone on 4/16/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MGManagedEntity;
@class NSPredicate;
@class NSManagedObjectContext;

@interface MGDataMergeOperation : NSObject

- (BOOL) mergeObjects: (NSArray *) sourceObjects managedEntity: (MGManagedEntity *) managedEntity subFilter: (NSPredicate *) subFilter context:(NSManagedObjectContext *) mergeContext error:(NSError **)error ;

@end
