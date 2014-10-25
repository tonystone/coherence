//
//  Tag.h
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Resource.h"
#import "CLTag.h"

@interface Tag : Resource <CLTag>

@property (nonatomic) NSNumber * position;

@end
