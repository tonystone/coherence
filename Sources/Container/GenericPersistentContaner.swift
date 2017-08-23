///
///  GenericPersistentContainer.swift
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
/// Private constants
///
private struct Default {

    struct PersistentStore {

        static let configurationName: String = "PF_DEFAULT_CONFIGURATION_NAME"

        ///
        /// Default PersistentStoreDescriptions array.
        ///
        static let configurations: [StoreConfiguration] = []
    }
}

///
/// There are activities that the CoreDataStack will do asynchronously as a result of various events.  GenericPersistentContainer currently
/// logs those events, if you would like to handle them yourself, you can set an error block which will be called to allow you to take
/// an alternate action.
///
public typealias AsyncErrorHandlerBlock = (Error) -> Void

///
/// Default block used to log Async errors if the user does not supply one
///
internal /// @testable
func defaultAsyncErrorHandlingBlock(tag tagName: String) -> AsyncErrorHandlerBlock {

    return { (error: Error) -> Void in
        logError(tagName) { "\(error)" }
    }
}

public enum GenericPersistentContainerErrors: Error {
    case invalidStoreDescription(String)
}

///
/// A persistent container that can be customized with specific ContextStrategy Context type.
///
public class GenericPersistentContainer<Strategy: ContextStrategyType>: PersistentStack {

    ///
    /// The name of this instance of GenericPersistentContainer.
    ///
    public let name: String

    ///
    /// Returns the `NSPersistentStoreCoordinate` instance that
    /// this `GenericPersistentContainer` contains.  It's type will
    /// be `CoordinatorType` which was given as a generic
    /// parameter during construction.
    ///
    public let persistentStoreCoordinator: NSPersistentStoreCoordinator

    ///
    /// The main context.
    ///
    /// This context should be used for read operations only.  Use it for all fetches and NSFetchedResultsControllers.
    ///
    /// It will be maintained automatically and be kept consistent.
    ///
    public var viewContext: NSManagedObjectContext {
        return contextStrategy.viewContext
    }

    ///
    /// Gets a new `BackgroundContext` that can be used for updating objects.
    ///
    /// - Note: This method and the returned `BackgroundContext` can be used on a background thread.  It can also be used on the main thread.
    ///
    public func newBackgroundContext<T: BackgroundContext>() -> T {
        logInfo(self.tag) { "Creating new background context of type `\(String(describing: T.self))`..." }
        defer {
            logInfo(self.tag) { "Background context created." }
        }
        return contextStrategy.newBackgroundContext()
    }

    fileprivate let tag: String
    fileprivate let errorHandlerBlock: AsyncErrorHandlerBlock

    fileprivate let contextStrategy: Strategy

    ///
    /// Initializes the receiver with the given name.
    ///
    /// - Note: By default, the provided `name` value is used to name the persistent store and is used to look up the name of the `NSManagedObjectModel` object to be used with the `GenericPersistentContainer` object.
    ///
    /// - Parameters:
    ///     - name:             The name of the model file in the bundle. The model will be located based on the name given.
    ///     - asyncErrorBlock:  An error handling block which will be called when an asynchronous error occurs (e.g. during a save of the main context to the persistent stores).
    ///     - logTag:           An optional String that will be used as the tag for logging (default is GenericPersistentContainer).  This is typically used if you are embedding GenericPersistentContainer in something else and you want to to log as your class.
    ///
    /// - Returns: A generic container initialized with the given name.
    ///
    public convenience init(name: String, asyncErrorBlock: AsyncErrorHandlerBlock? = nil, logTag tag: String = String(describing: GenericPersistentContainer.self)) {

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
    /// - Note: By default, the provided `name` value is used as the name of the persistent store associated with the container. Passing in the `NSManagedObjectModel` object overrides the lookup of the model by the provided name value.
    ///
    /// - Parameters:
    ///     - name:               The name of the model file in the bundle.
    ///     - managedObjectModel: A managed object model.
    ///     - asyncErrorBlock:    An error handling block which will be called when an asynchronous error occurs (e.g. during a save of the main context to the persistent stores).
    ///     - logTag:             An optional String that will be used as the tag for logging (default is GenericPersistentContainer).  This is typically used if you are embedding GenericPersistentContainer in something else and you want to to log as your class.
    ///
    /// - Returns: A generic container initialized with the given name and model.
    ///
    public required init(name: String, managedObjectModel model: NSManagedObjectModel, asyncErrorBlock: AsyncErrorHandlerBlock? = nil, logTag: String = String(describing: GenericPersistentContainer.self)) {

        self.name = name
        self.tag  = logTag

        self.errorHandlerBlock = asyncErrorBlock ?? defaultAsyncErrorHandlingBlock(tag: logTag)

        /// Create the coordinator
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

        self.contextStrategy = Strategy(persistentStoreCoordinator: self.persistentStoreCoordinator, errorHandler: self.errorHandlerBlock)
    }

    ///
    /// Attach a persistent store for a `StoreConfiguration`.
    ///
    /// - Parameters:
    ///     - url: (Optional) the `URL` for the location to attach the stores. If you do not pass this, the location will be defauled to the `defaultStoreLocation`.
    ///     - configuration: A `StoreConfiguration` that describes the store being attached.
    ///
    /// - Note: Calling this method will attempt to create the directory specified in the `at` parameter specified.  If a url is not specified, the `defaultStoreLocation` will be used and an attempt will be made to create that directory.
    ///
    @discardableResult
    public func attachPersistentStore(at url: URL, for configuration: StoreConfiguration) throws -> NSPersistentStore {

        ///
        /// Resolve the configuration passed before attaching store to expand
        /// the default values.
        ///
        /// - Note: This returns nil if it is an InMemoryStore
        ///
        let url = configuration.resolveURL(defaultStorePrefix: self.name, storeLocation: url)

        logInfo(self.tag) {

            var message = "Attaching persistent store '\(configuration.name ?? "default")' for type '\(configuration.type)'"
            if let url = url {
                message.append(" at: \(url.path)")
            }
            message.append(".")
            return message
        }

        /// If we have a file to check, make sure it is compatible.
        if let url = url {
            let fileManager = FileManager.default

            // Check the store for compatibility if requested by developer.
            if configuration.overwriteIncompatibleStore, configuration.type != NSInMemoryStoreType, fileManager.fileExists(atPath: url.path) {

                let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: configuration.type, at: url, options: configuration.options)

                if !persistentStoreCoordinator.managedObjectModel.isConfiguration(withName: configuration.name, compatibleWithStoreMetadata: metadata) {

                    logInfo(self.tag) { "Persistent store for configuration '\(configuration.name ?? "default")' is not compatible with the model, removing persistent store." }

                    try deleteIfExists(url.path)
                    try deleteIfExists("\(url.path)-shm")
                    try deleteIfExists("\(url.path)-wal")
                }
            }

            /// Make sure the directory is present
            try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        }

        let store = try persistentStoreCoordinator.addPersistentStore(ofType: configuration.type, configurationName:  configuration.name, at: url, options: configuration.options)

        logInfo(self.tag) { "Persistent store attached successfully." }

        return store
    }

    ///
    /// Detach a specific store.
    ///
    public func detach(persistentStore store: NSPersistentStore) throws {

        logInfo(self.tag) {

            var message = "Detaching persistent store '\(store.configurationName)' for type '\(store.type)'"
            if let url = store.url {
                message.append(" at: \(url.path)")
            }
            message.append(".")
            return message
        }
        
        try self.persistentStoreCoordinator.remove(store)
        
        logInfo(self.tag) { "Persistent store detached successfully." }
    }

    ///
    /// Attach the persistent stores specified in the array of `StoreConfiguration`s.
    ///
    /// - Parameters:
    ///     - url: (Optional) the `URL` for the location to attach the stores. If you do not pass this, the location will be defauled to the `defaultStoreLocation`.
    ///     - configurations: An array of `StoreConfiguration`s that describes the stores being attached.
    ///
    /// - Note: Calling this method will attempt to create the directory specified in the `at` parameter specified.  If a url is not specified, the `defaultStoreLocation` will be used and an attempt will be made to create that directory.
    ///
    @discardableResult
    public func attachPersistentStores(at url: URL, for configurations: [StoreConfiguration]) throws -> [NSPersistentStore] {

        var configurations = configurations

        /// If no configurations supplied, default the url
        if configurations.count == 0 {
            configurations.append(StoreConfiguration())
        }

        var stores: [NSPersistentStore] = []

        ///
        /// Attach each store in turn
        ///
        for configuration in configurations {
            stores.append(try self.attachPersistentStore(at: url, for: configuration))
        }
        return stores
    }

    ///
    /// Detach an array of stores.
    ///
    public func detach(persistentStores stores: [NSPersistentStore]) throws {

        for store in stores {
            try self.detach(persistentStore: store)
        }
    }

    fileprivate func deleteIfExists(_ path: String) throws {

        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: path) {
            
            logInfo(self.tag) { "Removing file \(path)." }
            
            try fileManager.removeItem(atPath: path)
        }
    }
}
