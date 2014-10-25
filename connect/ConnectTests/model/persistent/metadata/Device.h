//
//  Device.h
//  CloudScope
//
//  Created by Tony Stone on 5/1/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Resource.h"
#import "CLDevice.h"

@interface Device : Resource <CLDevice>

@property (nonatomic, retain) NSString * mgdid;
@property (nonatomic, retain) NSString * installedVersion;

@property (nonatomic) NSData * encryptedMgdid;
@property (nonatomic) NSString * deviceType;

@end
