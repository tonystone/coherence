//
//  Event.h
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AuditedResource.h"
#import "CLEvent.h"

@interface Event : AuditedResource <CLEvent>

@property (nonatomic) NSString * parentReference;
@property (nonatomic) NSString * parentName;
@property (nonatomic) NSNumber * ignore;
@property (nonatomic) NSNumber * read;
@property (nonatomic) NSNumber * position;

@end
