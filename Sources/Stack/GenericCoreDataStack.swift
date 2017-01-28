///
///  GenericCoreDataStack.swift
///
///  Copyright 2016 Tony Stone
///
///  Licensed under the Apache License, Version 2.0 (the "License");
///  you may not use this file except in compliance with the License.
///  You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///  Unless required by applicable law or agreed to in writing, software
///  distributed under the License is distributed on an "AS IS" BASIS,
///  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///  See the License for the specific language governing permissions and
///  limitations under the License.
///
///  Created by Tony Stone on 1/6/16.
///
import Foundation
import CoreData
import TraceLog

/**
    The name of the default configuration in the model.  If you have not 
    created any configurations, this will be the only configuration avaialble.

    Use this name if you override the options passed.
*/
public let defaultModelConfigurationName: String = "PF_DEFAULT_CONFIGURATION_NAME"

/**
    An option – when set to true – will check if the persistent store and the model are incompatible.
    If so, the underlying persistent store will be removed and replaced.
 */
public let overwriteIncompatibleStoreOption: String = "overwriteIncompatibleStoreOption"

/**
    Default options passed to attached and configure the persistent stores.
 */
public let defaultStoreOptions: [AnyHashable: Any] = [
    NSMigratePersistentStoresAutomaticallyOption    : true,
    NSInferMappingModelAutomaticallyOption          : true
]

/**
    If no storeType is passed in, this store type will be used
 */
public let defaultStoreType = NSSQLiteStoreType

/**
    PersistentStore configuration settings.
 */
public typealias PersistentStoreConfiguration = (storeType: String, storeOptions: [AnyHashable: Any]?, migrationManager: NSMigrationManager?)

/**
    Configuration options dictionary keyed by configuration name.  
    The name is the name you listed in your model.
 */
public typealias ConfigurationOptionsType = [String : PersistentStoreConfiguration]

/**
    The detault configuration options used to configure the persistent store when no override is supplied.
 */
public let defaultConfigurationOptions: ConfigurationOptionsType = [defaultModelConfigurationName : (storeType: defaultStoreType, storeOptions: defaultStoreOptions, migrationManager: nil)]

/**
    There are activities that the CoreDataStack will do asyncrhonously as a result of various events.  GenericCoreDataStack currently 
    logs those events, if you would like to handle them yourself, you can set an error block which will be called to allow you to take 
    an alternate action.
 */
public typealias asynErrorHandlerBlock = (NSError) -> Void

/**
    A Core Data stack that can be customized with specific NSPersistentStoreCoordinator and a NSManagedObjectContext Context type.
 */
open class GenericCoreDataStack<CoordinatorType: NSPersistentStoreCoordinator, ContextType: NSManagedObjectContext> {

    /// 
    /// The model this `GenericCoreDataStack` was constructed with.
    ///
    public let managedObjectModel: NSManagedObjectModel

    ///
    /// Returns the `NSPersistentStoreCoordinate` instance that
    /// this `GenericCoreDataStack` contains.  It's type will
    /// be `CoordinatorType` which was given as a generic
    /// parameter during construction.
    ///
    public let persistentStoreCoordinator: CoordinatorType

    fileprivate let tag: String
    fileprivate let mainContext: ContextType
    fileprivate let errorHandlerBlock: (_ error: NSError) -> Void

    ///
    ///  Initializes the receiver with a managed object model.
    ///
    ///   - parameters:
    ///      - managedObjectModel: A managed object model.
    ///      - configurationOptions: Optional configuration settings by persistent store config name (see ConfigurationOptionsType for structure)
    ///      - storeNamePrefix: An optional String which is appended to the beginning of the persistent store's name.
    ///      - logTag: An optional String that will be used as the tag for logging (default is GenericCoreDataStack).  This is typically used if you are embedding GenericCoreDataStack in something else and you want to to log as your class.
    ///
    public init(managedObjectModel model: NSManagedObjectModel, storeNamePrefix: String, configurationOptions options: ConfigurationOptionsType = defaultConfigurationOptions, asyncErrorBlock: ((_ error: NSError) -> Void)? = nil, logTag tag: String = String(describing: GenericCoreDataStack.self)) throws {
        
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
        mainContext = ContextType(concurrencyType: .mainQueueConcurrencyType)
        mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        //
        // Figure out where to put things
        //
        // Note: We use the applications bundle not the classes or modules.
        //
        let cachesURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        logInfo(tag) { "Store path: \(cachesURL.path)" }
        
        let configurations = managedObjectModel.configurations
        
        // There is only one so it's the default configuration
        if configurations.count == 1 {
            
            if let (storeType, storeOptions, migrationManager) = options[defaultModelConfigurationName] {
                
                let storeURL = cachesURL.appendingPathComponent("\(storeNamePrefix).\(storeType)")
                
                try self.addPersistentStore(storeType, configuration: nil, URL: storeURL, options: storeOptions, migrationManger: migrationManager)
                
            } else {
                let storeURL = cachesURL.appendingPathComponent("\(storeNamePrefix).\(defaultStoreType)")
                
                try self.addPersistentStore(defaultStoreType, configuration: nil, URL: storeURL, options: nil, migrationManger: nil)
            }
        } else {
            for configuration in configurations {
                
                if configuration != defaultModelConfigurationName {
                    
                    if let (storeType, storeOptions, migrationManager) = options[configuration] {
                        
                        let storeURL = cachesURL.appendingPathComponent("\(storeNamePrefix)\(configuration).\(storeType)")
                        
                        try self.addPersistentStore(storeType, configuration: configuration, URL: storeURL, options: storeOptions, migrationManger: migrationManager)
                        
                    } else {
                        let storeURL = cachesURL.appendingPathComponent("\(storeNamePrefix)\(configuration).\(defaultStoreType)")
                        
                        try self.addPersistentStore(defaultStoreType, configuration: configuration, URL: storeURL, options: nil, migrationManger: nil)
                    }
                }
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(GenericCoreDataStack.handleContextDidSaveNotification(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    ///
    /// Gets the main context.
    ///
    /// This context should be used for read operations only.  Use it for all fetches and NSFechtedResultsControllers.
    ///
    /// It will be maintained automatically and be kept consistent.
    ///
    /// - Warning: You should only use this context on the main thread.  If you must work on a background thread, use the method `edittContext` while on the thread.  See that method for more details
    ///
    open func mainThreadContext () -> NSManagedObjectContext {
        return mainContext
    }

    ///
    /// Gets a new NSManagedObjectContext that can be used for updating objects.
    ///
    /// At save time, resource manager will merge those changes back to the mainManagedObjectContext.
    ///
    /// - Note: This method and the returned NSManagedObjectContext can be used on a background thread as long as you get the context while on that thread.  It can also be used on the main thread if gotten while on the main thread.
    ///
    open func editContext () -> NSManagedObjectContext {
        
        logInfo(tag) { "Creating edit context for \(Thread.current)..." }
        
        let context = ContextType(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        context.parent = mainContext
        
        logInfo(tag) { "Edit context created." }
        
        return context
    }
    
    fileprivate func addPersistentStore(_ storeType: String, configuration: String?, URL storeURL: URL, options: [AnyHashable: Any]?, migrationManger migrator: NSMigrationManager?) throws {
        
        do {
            //
            // If a migration manager was supplied, try a migration first.
            //
            if let migrationManager = migrator {
                
                if let mappingModel = NSMappingModel(from: nil, forSourceModel: migrationManager.sourceModel, destinationModel: migrationManager.destinationModel) {
                    
                    // TODO: Rename old file first
                    try migrationManager.migrateStore(from: storeURL, sourceType: storeType, options: options, with: mappingModel, toDestinationURL: storeURL, destinationType: storeType, destinationOptions: options)
                }
            }
            
            logInfo(tag) { "Attaching persistent store \"\(storeURL.lastPathComponent)\" for type: \(storeType)."}

            let fileManager = FileManager.default
            let storePath = storeURL.path
            
            if fileManager.fileExists(atPath: storePath) {
                
                let storeShmPath = "\(storePath)-shm"
                let storeWalPath = "\(storePath)-wal"
                
                // Check the store for compatibility if requested by developer.
                if options?[overwriteIncompatibleStoreOption] as? Bool == true {
                    
                    logInfo(tag) { "Checking to see if persistent store is compatible with the model." }
                    
                    let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: storeType, at: storeURL, options: nil)
                    
                    if !persistentStoreCoordinator.managedObjectModel.isConfiguration(withName: configuration, compatibleWithStoreMetadata: metadata) {
                        
                        try deleteIfExists(storePath)
                        try deleteIfExists(storeShmPath)
                        try deleteIfExists(storeWalPath)
                    }
                }
            }
            
            logInfo(tag) { "Attaching new persistent store \"\(storeURL.lastPathComponent)\" for type: \(storeType)."}
            
            try persistentStoreCoordinator.addPersistentStore(ofType: storeType, configurationName:  configuration, at: storeURL, options: options)

            logInfo(tag) { "Persistent store attached successfully." }
            
        } catch let error as NSError where [NSMigrationError,
            NSMigrationConstraintViolationError,
            NSMigrationCancelledError,
            NSMigrationMissingSourceModelError,
            NSMigrationMissingMappingModelError,
            NSMigrationManagerSourceStoreError,
            NSMigrationManagerDestinationStoreError].contains(error.code) {
                
                let message = "Migration failed due to error: \(error.localizedDescription)"
                
                logError { message }
                
                throw NSError(domain: error.domain, code: error.code, userInfo: [NSLocalizedDescriptionKey: message])
                
        } catch let error as NSError {
            
            let message = "Failed to attached persistent store: \(error.localizedDescription)"
            
            logError { message }
            
            throw  NSError(domain: error.domain, code: error.code, userInfo: [NSLocalizedDescriptionKey: message])
        }
    }
    
    fileprivate func deleteIfExists(_ path: String) throws {
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: path) {
            
            logInfo(tag) { "Removing file \(path)." }
            
            try fileManager.removeItem(atPath: path)
        }
    }
    
    fileprivate dynamic func handleContextDidSaveNotification(_ notification: Notification)  {
        
        if let context = notification.object as? NSManagedObjectContext {
            
            //
            // If the saved context has it's parent set to our 
            // mainThreadContext auto save the main context
            //
            if context.parent == mainContext {
                
                mainContext.perform( { () -> Void in
                    do {
                        try self.mainContext.save()
                    } catch let error as NSError {
                        self.errorHandlerBlock(error)
                    }
                })
            }
        }
    }
}
