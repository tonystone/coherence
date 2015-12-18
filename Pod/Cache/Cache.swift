/**
 *   Cache.swift
 *
 *   Copyright 2015 Tony Stone
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *
 *   Created by Tony Stone on 12/12/15.
 */
import Foundation
import CoreData
import TraceLog

public final class Cache : NSObject {

    private typealias CoreDataStackType = CoreDataStack<Cache,PersistentStoreCoordinator, NSManagedObjectContext>
    
    private let coreDataStack: CoreDataStackType!   // Note: this is protected with a guard in the designated init method
    
    /**
        Initializes the receiver with a managed object model.

        - Parameter managedObjectModel: A managed object model.

        - Returns: The receiver, initialized with model.
    */
    public convenience init?(managedObjectModel model: NSManagedObjectModel) {
        self.init(managedObjectModel: model, persistentStoreOptions: [NSPersistentStoreFileProtectionKey : NSFileProtectionComplete,
                                                                      NSMigratePersistentStoresAutomaticallyOption: true,
                                                                      NSInferMappingModelAutomaticallyOption: true], migrationManager: nil)
    }
    
    /**
        Initializes the receiver with a managed object model and uses the migration manager to migrate the store.
     
        - Parameter managedObjectModel: A managed object model.
        - Parameter migrationManager: An instande of NSMigrationManager
     
        - Returns: The receiver, initialized with model.
     */
    public convenience init?(managedObjectModel model: NSManagedObjectModel, migrationManager: NSMigrationManager) {
        self.init(managedObjectModel: model, persistentStoreOptions: [NSPersistentStoreFileProtectionKey : NSFileProtectionComplete], migrationManager: migrationManager)
    }
    
    public convenience init?(managedObjectModel model: NSManagedObjectModel, persistentStoreOptions options: [NSObject : AnyObject]?) {
        self.init(managedObjectModel: model, persistentStoreOptions: options, migrationManager: nil)
    }
    
    public init?(managedObjectModel model: NSManagedObjectModel, persistentStoreOptions options: [NSObject : AnyObject]?, migrationManager: NSMigrationManager? = nil) {
        
        logInfo { "Initializing instance..." }
        
        coreDataStack = CoreDataStackType(namingPrefix: "cache", managedObjectModel: model, configurationOptions: [defaultModelConfigurationName : (storeType: NSSQLiteStoreType, storeOptions: options, migrationManager)])
        
        super.init()
        
        guard coreDataStack != nil else {
            return nil
        }
        
        self.start()
        
        logInfo { "Instance initialized." }
    }

    public func start () {
        logInfo { "Starting..." }
    
        logInfo {  "Started." }
    }

    public func stop () {
        logInfo { "Stopping..." }

        logInfo { "Stopped." }
    }
    
    public func mainThreadContext () -> NSManagedObjectContext {
        return coreDataStack.mainThreadContext
    }
    
    public func editContext () -> NSManagedObjectContext {
        return coreDataStack.editContext
    }
}
