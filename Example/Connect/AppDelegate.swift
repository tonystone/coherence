//
//  AppDelegate.swift
//  Connect
//
//  Created by Tony Stone on 08/21/2016.
//  Copyright (c) 2016 Tony Stone. All rights reserved.
//

import UIKit
import TraceLog
import CoreData
import Connect

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var persistentStoreCoordinator1: NSPersistentStoreCoordinator? = nil
    var persistentStoreCoordinator2: NSPersistentStoreCoordinator? = nil
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let bundle = NSBundle(forClass: self.dynamicType)
        let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        
        do {
            if let url = bundle.URLForResource("MetaData", withExtension: "mom") {
                if let model = NSManagedObjectModel(contentsOfURL: url) {
                    let persistentStoreCoordinator = PersistentStoreCoordinator(managedObjectModel: model)
                    
                    try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,   configuration: nil,   URL: NSURL(fileURLWithPath: "\(cachePath)/MetaData.sqlite"), options: nil)
                    
                    persistentStoreCoordinator1 = persistentStoreCoordinator
                }
            }
        } catch {
            logError { "failed to create CoreData stack for MetaData model: \(error)" }
        }
        
        do {
        
            if let url = bundle.URLForResource("RightScale", withExtension: "mom") {
                if let model = NSManagedObjectModel(contentsOfURL: url) {
                    let persistentStoreCoordinator = PersistentStoreCoordinator(managedObjectModel: model)
                    
                    try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,   configuration: "GlobalPersistentData",   URL: NSURL(fileURLWithPath: "\(cachePath)/GlobalPersistentData.sqlite"), options: nil)
                    try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,   configuration: "InstancePersistentData", URL: NSURL(fileURLWithPath: "\(cachePath)/InstancePersistentData.sqlite"), options: nil)
                    try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: "InstanceTransienttData", URL: nil, options: nil)
                    
                    persistentStoreCoordinator2 = persistentStoreCoordinator
                }
            }
        } catch {
            logError { "failed to create CoreData stack for RightScale model: \(error)" }
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

