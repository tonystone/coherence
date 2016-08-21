//
//  Resource.m
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import "Resource.h"


@implementation Resource


@dynamic name;
@dynamic resourceReference;
@dynamic textDescription;
@dynamic providerProperties;
@dynamic providerPrivateData;

@synthesize resourceReferenceLink;

/*
@synthesize name;
@synthesize resourceReference;
@synthesize textDescription;
@synthesize providerProperties;
@synthesize providerPrivateData;
*/
@end

@implementation Link
@dynamic rel, href;
@end