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
#import "CLProviderUserAccount.h"

@interface ProviderUserAccount : RootResource <CLProviderUserAccount>

@property (nonatomic) NSString * number;

@end
