//
//  MGConnect+EntityActionTests.m
//  MGConnect
//
//  Created by Tony Stone on 4/15/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectTestCommon.h"
#import "MGConnect+DataStoreConfiguration.h"
#import "MGConnect+EntityAction.h"
#import <CoreData/CoreData.h>
#import "MGEntityListAction.h"

@interface MGConnect_EntityActionTests : MGConnectTestCommon @end

@implementation MGConnect_EntityActionTests

- (void)setUp
{
    [super setUp];
    
    NSString * providerName  = @"RightScale";
    NSString * accountNumber = @"1000";
    
    [[MGConnect sharedManager] openDataStore: kConfigDataStore options: @{MGRemoveIncompatibleStoreOption: @YES}];
    [[MGConnect sharedManager] openDataStore: kCloudDataStore  options: @{MGRemoveIncompatibleStoreOption: @YES,
     @"GlobalPersistentData":   @{MGPersistentStoreTypeStoreKey: NSSQLiteStoreType,   MGPersistentStoreGroupIDStoreKey: providerName},
     @"InstancePersistentData": @{MGPersistentStoreTypeStoreKey: NSSQLiteStoreType,   MGPersistentStoreGroupIDStoreKey: providerName, MGPersistentStoreInstanceIDStoreKey: accountNumber},
     @"InstanceTransientData":  @{MGPersistentStoreTypeStoreKey: NSInMemoryStoreType, MGPersistentStoreGroupIDStoreKey: providerName, MGPersistentStoreInstanceIDStoreKey: accountNumber}}];
    
}

- (void)tearDown
{
//     Tear-down code here.
    
    [[MGConnect sharedManager] closeDataStore: kConfigDataStore];
    [[MGConnect sharedManager] closeDataStore: kCloudDataStore];
    
    [super tearDown];
}

//- (void) testEntityActionExecutionServerList {
//    
//    NSEntityDescription  * serverEntity = [NSEntityDescription entityForName: @"Server" inManagedObjectContext: [[MGConnect sharedManager] editManagedObjectContextForDataStore: kCloudDataStore]];
//    
//    [[MGConnect sharedManager] refreshEntity: serverEntity where: nil completionBlock: nil waitUntilDone: YES];
//}

@end
