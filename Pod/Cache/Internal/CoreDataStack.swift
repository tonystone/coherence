//
//  CoreDataStack.swift
//  Pods
//
//  Created by Tony Stone on 12/14/15.
//
//

import Foundation
import CoreData
import TraceLog


typealias ConfigurationOptionsType = [String : (storeType: String, storeOptions: [NSObject : AnyObject]?, migrationManager: NSMigrationManager?)]

internal let defaultModelConfigurationName: String = "Default"

internal let storeOptionsDefault: [NSObject : AnyObject] = [
    NSIgnorePersistentStoreVersioningOption         : true,
    NSMigratePersistentStoresAutomaticallyOption    : true,
    NSInferMappingModelAutomaticallyOption          : true,
    NSPersistentStoreFileProtectionKey              : NSFileProtectionComplete
]

internal let configurationOptionsDefault: ConfigurationOptionsType = [defaultModelConfigurationName : (storeType: NSSQLiteStoreType, storeOptions: nil, migrationManager: nil)]

internal class CoreDataStack<OwnerType, CoordinatorType: NSPersistentStoreCoordinator, ContextType: NSManagedObjectContext> : NSObject {

    private let managedObjectModel: NSManagedObjectModel
    private let persistentStoreCoordinator: CoordinatorType
    private let tag = String(OwnerType)

    // We allow access to the mainThreadContext
    internal let mainThreadContext: ContextType

    internal var editContext: ContextType {
        get {
            logInfo(tag) { "Creating edit context for \(NSThread .currentThread())..." }

            let context = ContextType(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
            context.parentContext = self.mainThreadContext

            logInfo(tag) { "Edit context created." }

            return context
        }
    }

    internal init?(namingPrefix: String, managedObjectModel model: NSManagedObjectModel, configurationOptions: ConfigurationOptionsType = configurationOptionsDefault) {
        
        managedObjectModel = model;
        
        // Create the coordinator
        persistentStoreCoordinator = CoordinatorType(managedObjectModel: managedObjectModel)

        // Now the main thread context
        mainThreadContext = ContextType(concurrencyType: .MainQueueConcurrencyType)
        mainThreadContext.persistentStoreCoordinator = self.persistentStoreCoordinator

        super.init()
        
        do {
            //
            // Figure out where to put things
            //
            // Note: We use the applications bundle not the classes or modules.
            //
            let cachesURL = try NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
            
            logInfo(tag) { "Store path: \(cachesURL.path ?? "Unknown")" }
            
            let configurations = managedObjectModel.configurations
            
            // There is only one so it's the default configuration
            if configurations.count == 1 {
                
                let storeURL = cachesURL.URLByAppendingPathComponent("\(namingPrefix)\(managedObjectModel.uniqueIdentifier())default.sqlite")
                
                if let (storeType, storeOptions, migrationManager) = configurationOptions[defaultModelConfigurationName] {
                    try self.addPersistentStore(storeType, configuration: nil, URL: storeURL, options: storeOptions, migrationManger: migrationManager)
                } else {
                    try self.addPersistentStore(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, migrationManger: nil)
                }
            } else {
                for configuration in configurations {
                    
                    if configuration != defaultModelConfigurationName {
                        
                        let storeURL = cachesURL.URLByAppendingPathComponent("\(namingPrefix)\(managedObjectModel.uniqueIdentifier())\(configuration).sqlite")
        
                        if let (storeType, storeOptions, migrationManager) = configurationOptions[configuration] {
                            try self.addPersistentStore(storeType, configuration: configuration, URL: storeURL, options: storeOptions, migrationManger: migrationManager)
                        } else {
                            try self.addPersistentStore(NSSQLiteStoreType, configuration: configuration, URL: storeURL, options: nil, migrationManger: nil)
                        }
                    }
                }
            }
            
        } catch  let error as NSError {
            
            logError(tag) {
                "Failed to initialize: \(error.localizedDescription)"
            }
            return nil
        }
    }
    
    private func addPersistentStore(storeType: String, configuration: String?, URL storeURL: NSURL, options: [NSObject : AnyObject]?, migrationManger migrator: NSMigrationManager?) throws {

        do {
            //
            // If a migration manager was supplied, try a migration first.
            //
            if let migrationManager = migrator {
                
                if let mappingModel = NSMappingModel(fromBundles: nil, forSourceModel: migrationManager.sourceModel, destinationModel: migrationManager.destinationModel) {
                    
                    // TODO: Rename old file first
                    try migrationManager.migrateStoreFromURL(storeURL, type: storeType, options: options, withMappingModel: mappingModel, toDestinationURL: storeURL, destinationType: storeType, destinationOptions: options)
                }
            }
            
            logInfo(tag) {
                "Attaching persistent store \"\(storeURL.lastPathComponent ?? "Unknown")\" for type: \(persistentStoreType)."
            }
            try persistentStoreCoordinator.addPersistentStoreWithType(storeType, configuration:  configuration, URL: storeURL, options: options)
            
            logInfo(tag) {
                "Persistent store attached successfully."
            }
            
        } catch let error as NSError where [NSMigrationError,
                                            NSMigrationConstraintViolationError,
                                            NSMigrationCancelledError,
                                            NSMigrationMissingSourceModelError,
                                            NSMigrationMissingMappingModelError,
                                            NSMigrationManagerSourceStoreError,
                                            NSMigrationManagerDestinationStoreError].contains(error.code) {
                                                
            logError { "Migration failed due to error: \(error.localizedDescription)" }
                                                
            throw error
        } catch let error as NSError {
            logError { "Failed to attached persistent store: \(error.localizedDescription)" }
            throw error
        }
    }
}
