//
//  ProviderUser+Extensions.h
//  CloudBase
//
//  Created by Tony Stone on 10/8/11.
//  Copyright 2011 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProviderUser.h"

@class ProviderUserAccount;
@class EventFeed;

@interface ProviderUser (Extensions) 
@property (nonatomic, retain) NSString              * clearTextPassword;

@property (nonatomic, readonly) NSArray             * accounts;
@property (nonatomic, readonly) ProviderUserAccount * selectedAccount;

@end
