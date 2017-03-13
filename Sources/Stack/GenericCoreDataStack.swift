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

///
/// Location to store the persistent stores.
///
private let coreDataStackStoreDirectory: FileManager.SearchPathDirectory = .documentDirectory

///
/// The name of the default configuration in the model.  If you have not
/// created any configurations, this will be the only configuration avaialble.
///
/// Use this name if you override the options passed.
///
public let defaultModelConfigurationName: String = "PF_DEFAULT_CONFIGURATION_NAME"

///
/// An option – when set to true – will check if the persistent store and the model are incompatible.
/// If so, the underlying persistent store will be removed and replaced.
///
public let overwriteIncompatibleStoreOption: String = "overwriteIncompatibleStoreOption"

///
/// Default options passed to attached and configure the persistent stores.
///
public let defaultStoreOptions: [AnyHashable: Any] = [:]

///
/// If no storeType is passed in, this store type will be used
///
public let defaultStoreType = NSSQLiteStoreType

///
/// PersistentStore configuration settings.
///
public typealias PersistentStoreConfiguration = (storeType: String, storeOptions: [AnyHashable: Any]?)

///
/// Configuration options dictionary keyed by configuration name.
/// The name is the name you listed in your model.
///
public typealias ConfigurationOptionsType = [String : PersistentStoreConfiguration]

///
/// The detault configuration options used to configure the persistent store when no override is supplied.
///
public let defaultConfigurationOptions: ConfigurationOptionsType = [defaultModelConfigurationName : (storeType: defaultStoreType, storeOptions: defaultStoreOptions)]

///
/// There are activities that the CoreDataStack will do asyncrhonously as a result of various events.  GenericCoreDataStack currently
/// logs those events, if you would like to handle them yourself, you can set an error block which will be called to allow you to take
/// an alternate action.
///
public typealias AsynErrorHandlerBlock = (Error) -> Void

///
/// A Core Data stack that can be customized with specific NSPersistentStoreCoordinator and a NSManagedObjectContext Context type.
///
open class GenericCoreDataStack<CoordinatorType: NSPersistentStoreCoordinator, ViewContextType: NSManagedObjectContext, BackgroundContextType: NSManagedObjectContext>: CoreDataStack {

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

    ///
    /// The main context.
    ///
    /// This context should be used for read operations only.  Use it for all fetches and NSFechtedResultsControllers.
    ///
    /// It will be maintained automatically and be kept consistent.
    ///
    /// - Warning: You should only use this context on the main thread.  If you must work on a background thread, use the method `edittContext` while on the thread.  See that method for more details
    ///
    public var viewContext: ViewContextType

    ///
    /// Gets a new NSManagedObjectContext that can be used for updating objects.
    ///
    /// At save time, resource manager will merge those changes back to the mainManagedObjectContext.
    ///
    /// - Note: This method and the returned NSManagedObjectContext can be used on a background thread as long as you get the context while on that thread.  It can also be used on the main thread if gotten while on the main thread.
    ///
    public func newBackgroundContext() -> BackgroundContextType {

        logInfo(tag) { "Creating edit context for \(Thread.current)..." }

        let context = BackgroundContextType(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator

        logInfo(tag) { "Edit context created." }

        return context
    }

    fileprivate let rootContext: NSManagedObjectContext
    fileprivate let tag: String
    fileprivate let errorHandlerBlock: AsynErrorHandlerBlock

    public let name: String

    ///
    /// Initializes a CoreData stack with the given name.
    ///
    /// - Note: By default, the provided `name` value is used to name the persistent store and is used to look up the name of the `NSManagedObjectModel` object to be used with the `GenericCoreDataStack` object.
    ///
    /// - Parameters:
    ///     - name: The name of the model file in the bundle. The model will be located based on the name given.
    ///     - logTag: An optional String that will be used as the tag for logging (default is GenericCoreDataStack).  This is typically used if you are embedding GenericCoreDataStack in something else and you want to to log as your class.
    ///
    /// - Returns: A generic core data stack initialized with the given name.
    ///
    public convenience init(name: String, asyncErrorBlock: AsynErrorHandlerBlock? = nil, logTag tag: String = String(describing: GenericCoreDataStack.self)) {

        let url = abortIfNil(message: "Could not locate model `\(name)` in any bundle.") {
            return Bundle.url(forManagedObjectModelName: name)
        }

        let model = abortIfNil(message: "Failed to load model at \(url).") {
            return NSManagedObjectModel(contentsOf: url)
        }
        self.init(name: name, managedObjectModel: model, asyncErrorBlock: asyncErrorBlock, logTag: tag)
    }

    ///
    /// Initializes the receiver with the given name and a managed object model.
    ///
    /// - Note: By default, the provided `name` value of the stack is used as the name of the persisent store associated with the stack. Passing in the `NSManagedObjectModel` object overrides the lookup of the model by the provided name value.
    ///
    /// - Parameters:
    ///     - name: The name of the model file in the bundle.
    ///     - managedObjectModel: A managed object model.
    ///     - logTag: An optional String that will be used as the tag for logging (default is GenericCoreDataStack).  This is typically used if you are embedding GenericCoreDataStack in something else and you want to to log as your class.
    ///
    /// - Returns: A generic core data stack initialized with the given name and model.
    ///
    public required init(name: String, managedObjectModel model: NSManagedObjectModel, asyncErrorBlock: AsynErrorHandlerBlock? = nil, logTag tag: String = String(describing: GenericCoreDataStack.self)) {

        self.name = name

        self.managedObjectModel = model
        self.tag = tag

        if let asyncErrorBlock = asyncErrorBlock {
            self.errorHandlerBlock = asyncErrorBlock
        } else {
            self.errorHandlerBlock = { (error: Error) -> Void in
                logError { "\(error)" }
            }
        }

        /// Create the coordinator
        self.persistentStoreCoordinator = CoordinatorType(managedObjectModel: managedObjectModel)

        /// Create teh root context for saving
        self.rootContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.rootContext.persistentStoreCoordinator = self.persistentStoreCoordinator

        /// Now the main thread context
        self.viewContext = ViewContextType(concurrencyType: .mainQueueConcurrencyType)
        self.viewContext.parent = self.rootContext

        NotificationCenter.default.addObserver(self, selector: #selector(GenericCoreDataStack.handleContextDidSaveNotification(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func loadPersistentStores(configurationOptions options: ConfigurationOptionsType = defaultConfigurationOptions) throws {
        //
        // Figure out where to put things
        //
        // Note: We use the applications bundle not the classes or modules.
        //
        let baseURL = try FileManager.default.url(for: coreDataStackStoreDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

        try self.loadPersistentStores(storeLocationURL: baseURL, configurationOptions: options)
    }

    ///
    ///  Initializes the receiver with a managed object model.
    ///
    ///   - parameters:
    ///      - managedObjectModel: A managed object model.
    ///      - configurationOptions: Optional configuration settings by persistent store config name (see ConfigurationOptionsType for structure)
    ///      - storeURL: An optional String which is appended to the beginning of the persistent store's name.
    ///      - logTag: An optional String that will be used as the tag for logging (default is GenericCoreDataStack).  This is typically used if you are embedding GenericCoreDataStack in something else and you want to to log as your class.
    ///
    public func loadPersistentStores(storeLocationURL: URL, configurationOptions options: ConfigurationOptionsType = defaultConfigurationOptions) throws {

        logInfo(tag) { "Store path: \(storeLocationURL)" }
        
        let configurations = managedObjectModel.configurations
        
        // There is only one so it's the default configuration
        if configurations.count == 1 {

            let storeName: String

            if self.name.characters.count > 0 {
                storeName = self.name
            } else {
               storeName = "default"
            }

            if let (storeType, storeOptions) = options[defaultModelConfigurationName] {
                
                let storeURL = storeLocationURL.appendingPathComponent("\(storeName).\(storeType.lowercased())")
                
                try self.addPersistentStore(storeType, configuration: nil, URL: storeURL, options: storeOptions)
                
            } else {
                let storeURL = storeLocationURL.appendingPathComponent("\(storeName).\(defaultStoreType.lowercased())")
                
                try self.addPersistentStore(defaultStoreType, configuration: nil, URL: storeURL, options: nil)
            }
        } else {
            for configuration in configurations {

                let storeName: String  = "\(self.name)\(configuration.lowercased())"

                if configuration != defaultModelConfigurationName {
                    
                    if let (storeType, storeOptions) = options[configuration] {
                        
                        let storeURL = storeLocationURL.appendingPathComponent("\(storeName).\(storeType.lowercased())")
                        
                        try self.addPersistentStore(storeType, configuration: configuration, URL: storeURL, options: storeOptions)
                        
                    } else {
                        let storeURL = storeLocationURL.appendingPathComponent("\(storeName).\(defaultStoreType.lowercased())")
                        
                        try self.addPersistentStore(defaultStoreType, configuration: configuration, URL: storeURL, options: nil)
                    }
                }
            }
        }

    }

    fileprivate func addPersistentStore(_ storeType: String, configuration: String?, URL storeURL: URL, options: [AnyHashable: Any]?) throws {
            
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

    }

    fileprivate func deleteIfExists(_ path: String) throws {

        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: path) {
            
            logInfo(tag) { "Removing file \(path)." }
            
            try fileManager.removeItem(atPath: path)
        }
    }

    @inline(__always)
    fileprivate func isEditContext(_ context: NSManagedObjectContext) -> Bool {
        ///
        /// Note: you must use the identity operator `===` for the comparison.
        ///
        return context.persistentStoreCoordinator === self.persistentStoreCoordinator &&    /// Ensure it is one of this instances contexts
               context !== self.rootContext &&                                              /// and that is it not the rootContext
               context !== self.viewContext                                                 /// and not the main context
    }

    fileprivate dynamic func handleContextDidSaveNotification(_ notification: Notification)  {
        
        if let context = notification.object as? NSManagedObjectContext {
            
            ///
            /// If the context has it's persistentStoreCoordinate as our coordinator
            /// and it does not have a parent, the context is one of our edit
            /// contexts so we propogate the changes to our main context and
            /// up the stack.

            if isEditContext(context) {
                
                self.viewContext.perform {

                    do {
                        ///
                        /// Merge the changes from the edit context to the main
                        /// conntext.
                        ///
                        self.viewContext.mergeChanges(fromContextDidSave: notification)

                        ///
                        /// Now save it to propagate the changes to the root.
                        ///
                        try self.viewContext.save()

                        ////
                        /// And finally save the root context to the persistent store
                        /// on a background thread.
                        ///
                        self.rootContext.perform {
                            do {
                                try self.rootContext.save()
                            } catch {
                                self.errorHandlerBlock(error)
                            }
                        }
                    } catch {
                        self.errorHandlerBlock(error)
                    }
                }
            }
        }
    }
}
