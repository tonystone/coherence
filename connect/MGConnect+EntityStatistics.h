//
//  MGConnect+EntityStatistics.h
//  MGConnect
//
//  Created by Tony Stone on 4/1/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnect.h"

@class NSManagedObjectModel;
@class NSEntityDescription;


@protocol MGEntityStatisticsService <NSObject>

@optional
    - (void) start;
    - (void) stop;

@required
    - (void) recalculateStatistics: (id) aManagedObjectModelOrEntityDescription;

@end


@interface MGConnect (EntityStatistics)

- (void) registerStatisticsService: (NSObject <MGEntityStatisticsService> *) statisticsService managedObjectModel: (NSManagedObjectModel *) aManagedObjectModel;
- (void) registerStatisticsService: (NSObject <MGEntityStatisticsService> *) statisticsService  entityDescription: (NSEntityDescription *)  anEntityDescription;

@end
