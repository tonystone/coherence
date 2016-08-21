//
//  GlobalSettings+Extensions.h
//  CloudBase
//
//  Created by Tony Stone on 10/8/11.
//  Copyright 2011 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalSettings.h"

@class RootResource;
@class ProviderUser;

@interface GlobalSettings (Extensions)
@property (nonatomic, readonly) RootResource * selectedRoot;
@property (nonatomic, readonly) ProviderUser * selectedUser;
- (NSArray *) providerUsers;
@end
