//
//  User.h
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RootResource.h"
#import "CLProviderUser.h"

@interface ProviderUser : RootResource <CLProviderUser>

@property (nonatomic) NSString * providerName;
@property (nonatomic) NSString * providerReference;
@property (nonatomic) id         providerData;
@property (nonatomic) NSString * email;
@property (nonatomic) NSString * selectedAccountReference;
@property (nonatomic) NSData   * encryptedPassword;
@property (nonatomic) NSString * eventFeedPath;
@property (nonatomic) NSString * deviceReference;

@end
