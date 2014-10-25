//
//  RootResource+Extensions.h
//  CloudBase
//
//  Created by Tony Stone on 11/5/11.
//  Copyright (c) 2011 Mobile Grid, Inc. All rights reserved.
//

#import "RootResource.h"

@class GlobalSettings;

@interface RootResource (Extensions)
@property (nonatomic, readonly) NSArray        * childResources;
@property (nonatomic, readonly) GlobalSettings * globalSettings;
@end
