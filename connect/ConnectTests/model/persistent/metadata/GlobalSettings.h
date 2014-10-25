//
//  GlobalSettings.h
//  CloudScope
//
//  Created by Tony Stone on 2/22/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Resource.h"


@interface GlobalSettings : Resource

@property (nonatomic) NSString * selectedRootReference;
@property (nonatomic) NSNumber * rememberPasswords;
@property (nonatomic) NSString * selectedUserReference;
@property (nonatomic) NSNumber * advancedMode;
@property (nonatomic) NSNumber * autoLogoutInactivityTime;
@property (nonatomic) NSString * deviceReference;

@end
