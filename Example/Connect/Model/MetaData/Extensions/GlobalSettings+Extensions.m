//
//  GlobalSettings+Extensions.m
//  CloudBase
//
//  Created by Tony Stone on 10/8/11.
//  Copyright 2011 Mobile Grid, Inc. All rights reserved.
//

#import "GlobalSettings+Extensions.h"
#import "RootResource.h"
#import "ProviderUser.h"

@implementation GlobalSettings (Extensions)

- (RootResource *) selectedRoot {
    return [[self valueForKey: @"fetchSelectedRoot"] lastObject];
}

- (ProviderUser *) selectedUser {
    return [[self valueForKey: @"fetchSelectedUser"] lastObject];
}

- (NSArray *) providerUsers {
    return [self valueForKey: @"fetchProviderUsers"];
}

@end
