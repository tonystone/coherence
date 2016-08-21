//
//  Executable.h
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VersionedResource.h"

@interface Executable : VersionedResource

@property (nonatomic) NSString * phase;
@property (nonatomic) NSString * recipe;
@property (nonatomic) NSNumber * position;
@property (nonatomic) NSString * parentReference;
@property (nonatomic) NSString * script;
@property (nonatomic) NSString * scriptReference;

@end
