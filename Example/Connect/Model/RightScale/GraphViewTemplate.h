//
//  GraphViewTemplate.h
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Resource.h"

@interface GraphViewTemplate : Resource

@property (nonatomic) NSString * verticalLabel;
@property (nonatomic) NSDecimalNumber * limitLower;
@property (nonatomic) NSDecimalNumber * limitUpper;
@property (nonatomic) NSNumber * autoGrid;
@property (nonatomic) NSNumber * logarithmicScaling;
@property (nonatomic) NSNumber * unitsDecimalPlaces;
@property (nonatomic) NSNumber * unitsBase;
@property (nonatomic) NSNumber * rigidBoundariesMode;
@property (nonatomic) NSNumber * unitsLength;
@property (nonatomic) NSNumber * baseValue;
@property (nonatomic) NSNumber * gridStep;
@property (nonatomic) id plotLineColors;
@property (nonatomic) id plotTitles;
@property (nonatomic) NSNumber * unitsExponent;
@property (nonatomic) NSNumber * autoScale;

@end
