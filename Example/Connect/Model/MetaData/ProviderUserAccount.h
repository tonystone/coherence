//
//  UserAccount.h
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RootResource.h"

@interface ProviderUserAccount : RootResource

@property (nonatomic) NSString * number;

@end
