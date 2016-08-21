//
//  Resource+Extensions.h
//  CloudBase
//
//  Created by Tony Stone on 11/5/11.
//  Copyright (c) 2011 Mobile Grid, Inc. All rights reserved.
//

#import "Resource.h"

@interface Resource (Extensions)
- (NSString *) resourceId;
- (NSArray *) tags;
- (NSDictionary *) dictionaryWithValuesAndKeys;
@end
