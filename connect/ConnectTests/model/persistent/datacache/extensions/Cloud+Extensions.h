//
//  Cloud+Extensions.h
//  CloudBase
//
//  Created by Tony Stone on 10/11/11.
//  Copyright 2011 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cloud.h"

@interface Cloud (Extensions)
- (NSArray *) datacenters;
- (NSArray *) instanceTypes;
@end
