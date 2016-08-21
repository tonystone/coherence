//
//  MGAppDelegate.m
//  Connect
//
//  Created by Tony Stone on 08/20/2016.
//  Copyright (c) 2016 Tony Stone. All rights reserved.
//

#import "MGAppDelegate.h"
@import Connect;

#define kConfigDataStore @"metadata"
#define kCloudDataStore  @"rightscale"

@implementation MGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString * providerName  = @"RightScale";
    NSString * accountNumber = @"1000";
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    NSURL * metaDataModelURL = [bundle URLForResource: @"MetaData" withExtension: @"mom"];
    NSManagedObjectModel * metaDataModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: metaDataModelURL];
    
    NSURL * dataCacheModelURL = [bundle URLForResource: @"RightScale" withExtension: @"mom"];
    NSManagedObjectModel * dataCacheModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: dataCacheModelURL];
    
    [[MGConnect sharedManager] registerDataStore: kConfigDataStore managedObjectModel: metaDataModel];
    [[MGConnect sharedManager] registerDataStore: kCloudDataStore managedObjectModel: dataCacheModel];
    
    [[MGConnect sharedManager] openDataStore: kConfigDataStore options: @{MGRemoveIncompatibleStoreOption: @YES}];
    [[MGConnect sharedManager] openDataStore: kCloudDataStore  options: @{MGRemoveIncompatibleStoreOption: @YES,
                                                                                  @"GlobalPersistentData":   @{MGPersistentStoreTypeStoreKey: NSSQLiteStoreType,   MGPersistentStoreGroupIDStoreKey: providerName},
                                                                                  @"InstancePersistentData": @{MGPersistentStoreTypeStoreKey: NSSQLiteStoreType,   MGPersistentStoreGroupIDStoreKey: providerName, MGPersistentStoreInstanceIDStoreKey: accountNumber},
                                                                                  @"InstanceTransientData":  @{MGPersistentStoreTypeStoreKey: NSInMemoryStoreType, MGPersistentStoreGroupIDStoreKey: providerName, MGPersistentStoreInstanceIDStoreKey: accountNumber}}];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
