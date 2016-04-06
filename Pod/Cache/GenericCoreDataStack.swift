/**
 *   GenericCoreDataStack.swift
 *
 *   Copyright 2016 Tony Stone
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
 *   Created by Tony Stone on 1/6/16.
 */
import Foundation
import CoreData
import TraceLog

/**
    The name of the default configuration in the model.  If you have not 
    created any configurations, this will be the only configuration avaialble.

    Use this name if you override the options passed.
*/
public let defaultModelConfigurationName: String = "Default"

/**
    An option – when set to true – will check if the persistent store and the model are incompatible.
    If so, the underlying persistent store will be removed and replaced.
 */
public let CCOverwriteIncompatibleModelOption: String = "overwriteIncompatibleModelOption"

/**
    Default options passed to attached and configure the persistent stores.
 */
public let defaultStoreOptions: [NSObject : AnyObject] = [
    NSIgnorePersistentStoreVersioningOption         : true,
    NSMigratePersistentStoresAutomaticallyOption    : true,
    NSInferMappingModelAutomaticallyOption          : true,
    NSPersistentStoreFileProtectionKey              : NSFileProtectionComplete
]

/**
    PersistentStore configuration settings.
 */
public typealias PersistentStoreConfiguration = (storeType: String, storeOptions: [NSObject : AnyObject]?, migrationManager: NSMigrationManager?)

/**
    Configuration options dictionary keyed by configuration name.  
    The name is the name you listed in your model.
 */
public typealias ConfigurationOptionsType = [String : PersistentStoreConfiguration]

/**
    The detault configuration options used to configure the persistent store when no override is supplied.
 */
public let defaultConfigurationOptions: ConfigurationOptionsType = [defaultModelConfigurationName : (storeType: NSSQLiteStoreType, storeOptions: defaultStoreOptions, migrationManager: nil)]

/**
    There are activities that the CoreDataStack will do asyncrhonously as a result of various events.  GenericCoreDataStack currently 
    logs those events, if you would like to handle them yourself, you can set an error block which will be called to allow you to take 
    an alternate action.
 */
public typealias asynErrorHandlerBlock = (NSError) -> Void

/**
    A Core Data stack that can be customized with specific NSPersistentStoreCoordinator and a NSManagedObjectContext Context type.
 */
public class GenericCoreDataStack<CoordinatorType: NSPersistentStoreCoordinator, ContextType: NSManagedObjectContext> {
    
    private let managedObjectModel: NSManagedObjectModel
    private let persistentStoreCoordinator: CoordinatorType
    private let tag: String
    private let mainContext: ContextType
    private let errorHandlerBlock: (error: NSError) -> Void
    
    /**
        Initializes the receiver with a managed object model.
     
        - Parameter managedObjectModel: A managed object model.
        - configurationOptions: Optional configuration settings by persistent store config name (see ConfigurationOptionsType for structure)
        - namingPrefix: An optional String which is appended to the beginning of the persistent store names.
        - logTag: An optional String that will be used as the tag for logging (default is GenericCoreDataStack).  This is typically used if you are embedding GenericCoreDataStack in something else and you want to to log as your class.
     */
    public init?(managedObjectModel model: NSManagedObjectModel, configurationOptions options: ConfigurationOptionsType = defaultConfigurationOptions, asyncErrorBlock: ((error: NSError) -> Void)? = nil,  namingPrefix prefix: String = "cache", logTag tag: String = String(GenericCoreDataStack.self)) {
        
        self.managedObjectModel = model
        self.tag = tag
    
        if let asyncErrorBlock = asyncErrorBlock {
            self.errorHandlerBlock = asyncErrorBlock
        } else {
            self.errorHandlerBlock = { (error: NSError) -> Void in
                logError { error.localizedDescription }
            }
        }
        
        // Create the coordinator
        persistentStoreCoordinator = CoordinatorType(managedObjectModel: managedObjectModel)
        
        // Now the main thread context
        mainContext = ContextType(concurrencyType: .MainQueueConcurrencyType)
        mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
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
                
                let storeURL = cachesURL.URLByAppendingPathComponent("\(prefix)\(managedObjectModel.uniqueIdentifier())default.sqlite")
                
                if let (storeType, storeOptions, migrationManager) = options[defaultModelConfigurationName] {
                    try self.addPersistentStore(storeType, configuration: nil, URL: storeURL, options: storeOptions, migrationManger: migrationManager)
                } else {
                    try self.addPersistentStore(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, migrationManger: nil)
                }
            } else {
                for configuration in configurations {
                    
                    if configuration != defaultModelConfigurationName {
                        
                        let storeURL = cachesURL.URLByAppendingPathComponent("\(prefix)\(managedObjectModel.uniqueIdentifier())\(configuration).sqlite")
                        
                        if let (storeType, storeOptions, migrationManager) = options[configuration] {
                            try self.addPersistentStore(storeType, configuration: configuration, URL: storeURL, options: storeOptions, migrationManger: migrationManager)
                        } else {
                            try self.addPersistentStore(NSSQLiteStoreType, configuration: configuration, URL: storeURL, options: nil, migrationManger: nil)
                        }
                    }
                }
            }
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleContextDidSaveNotification:", name: NSManagedObjectContextDidSaveNotification, object: nil)
            
        } catch  let error as NSError {
            
            logError(tag) {
                "Failed to initialize: \(error.localizedDescription)"
            }
            return nil
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public func mainThreadContext () -> NSManagedObjectContext {
        return mainContext
    }
    
    public func editContext () -> NSManagedObjectContext {
        
        logInfo(tag) { "Creating edit context for \(NSThread .currentThread())..." }
        
        let context = ContextType(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        context.parentContext = mainContext
        
        logInfo(tag) { "Edit context created." }
        
        return context
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
            
            logInfo(tag) { "Attaching persistent store \"\(storeURL.lastPathComponent ?? "Unknown")\" for type: \(persistentStoreType)."}

            let persistentStore = try persistentStoreCoordinator.addPersistentStoreWithType(storeType, configuration:  configuration, URL: storeURL, options: options)

            if options?[CCOverwriteIncompatibleModelOption] as? Bool == true {

                let model = persistentStoreCoordinator.managedObjectModel
                let metadata = persistentStoreCoordinator.metadataForPersistentStore(persistentStore)

                logInfo(tag) { "Checking to see if persistent store is compatible with the model." }

                if model.isConfiguration(configuration, compatibleWithStoreMetadata: metadata) {

                    logInfo(tag) { "Model is incompatible. Attempting to remove the persistent store." }
                    try persistentStoreCoordinator.removePersistentStore(persistentStore)

                    logInfo(tag) { "Attempting to remove file \(storeURL) and -shm and -wal files" }
                    if let path = storeURL.path {

                        deleteIfExists(fileURL: storeURL)
                        deleteIfExists(fileURL: NSURL(fileURLWithPath: "\(path)-shm"))
                        deleteIfExists(fileURL: NSURL(fileURLWithPath: "\(path)-wal"))
                    }

                    logInfo(tag) { "Attaching new persistent store \"\(storeURL.lastPathComponent ?? "Unknown")\" for type: \(persistentStoreType)."}
                    try persistentStoreCoordinator.addPersistentStoreWithType(storeType, configuration:  configuration, URL: storeURL, options: options)
                }
            }

            logInfo(tag) { "Persistent store attached successfully." }
            
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
    
    private func deleteIfExists(fileURL url: NSURL) {
        
        let fileManager = NSFileManager.defaultManager()
        
        do {
            try fileManager.removeItemAtURL(url)
            
        } catch let error as NSError {
            logError { "Could not delete file \(url), error was: \(error.localizedDescription)" }
        }
    }
    
    private dynamic func handleContextDidSaveNotification(notification: NSNotification)  {
        
        if let context = notification.object as? NSManagedObjectContext {
            
            //
            // If the saved context has it's parent set to our 
            // mainThreadContext auto save the main context
            //
            if context.parentContext == mainContext {
                
                mainContext.performBlockAndWait({ () -> Void in
                    do {
                        try self.mainContext.save()
                    } catch let error as NSError {
                        self.errorHandlerBlock(error: error)
                    }
                })
            }
        }
    }
}
