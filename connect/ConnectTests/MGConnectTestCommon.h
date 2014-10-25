//
//  MGConnectTestCommon.h
//  MGConnect
//
//  Created by Tony Stone on 4/15/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#define kCurrentlyDefinedProvider @"RightScale"

#define kConfigDataStore @"configuration"
#define kCloudDataStore  @"cloud"

@interface MGConnectTestCommon : SenTestCase 

- (void) login;

@end
