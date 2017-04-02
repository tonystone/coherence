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
let defaultAsyncErrorHandlingBlock = { (error: Error) -> Void in
    logError { "\(error)" }
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
    /// The model this `GenericPersistentContainer` was constructed with.
    ///
    public let managedObjectModel: NSManagedObjectModel

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
    /// - Warning: You should only use this context on the main thread.  If you must work on a background thread, use the method `newBackgroundContext` while on the thread.  See that method for more details
    ///
    public var viewContext: NSManagedObjectContext {
        return contextStrategy.viewContext
    }

    ///
    /// Gets a new NSManagedObjectContext that can be used for updating objects.
    ///
    /// At save time, Connect will merge those changes back to the viewContext.
    ///
    /// - Note: This method and the returned NSManagedObjectContext can be used on a background thread as long as you get the context while on that thread.  It can also be used on the main thread if gotten while on the main thread.
    ///
    public func newBackgroundContext<T: NSManagedObjectContext>() -> T {
        logInfo { "Creating new background context of type `\(String(describing: T.self))`..." }
        defer {
            logInfo { "Background context created." }
        }
        return contextStrategy.newBackgroundContext()
    }

    ///
    /// The persistent store configurations used to create the persistent stores referenced by this instance.
    ///
    public var storeConfigurations: [StoreConfiguration]

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
    public required init(name: String, managedObjectModel model: NSManagedObjectModel, asyncErrorBlock: AsyncErrorHandlerBlock? = nil, logTag tag: String = String(describing: GenericPersistentContainer.self)) {

        self.name                        = name
        self.managedObjectModel          = model
        self.storeConfigurations         = Default.PersistentStore.configurations
        self.tag                         = tag

        self.errorHandlerBlock = asyncErrorBlock ?? defaultAsyncErrorHandlingBlock

        /// Create the coordinator
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        self.contextStrategy = Strategy(persistentStoreCoordinator: self.persistentStoreCoordinator, errorHandler: self.errorHandlerBlock)
    }

    public func loadPersistentStores() throws {

        var configurations = self.storeConfigurations

        /// If no configurations supplied, default the url
        if configurations.count == 0 {
            configurations.append(StoreConfiguration(url: GenericPersistentContainer.defaultStoreLocation().appendingPathComponent("\(self.name).sqlite")))
        }

        ///
        /// Load each store in turn
        ///
        for configuration in configurations {
            try self.addPersistentStore(for: configuration)
        }
    }

    fileprivate func addPersistentStore(for configuration: StoreConfiguration) throws {

        let fileManager = FileManager.default

        // Check the store for compatibility if requested by developer.
        if configuration.overwriteIncompatibleStore,
           configuration.type != NSInMemoryStoreType,
           let url = configuration.url,
           fileManager.fileExists(atPath: url.path) {

            logInfo(tag) { "Checking to see if persistent store is compatible with the model." }
            
            let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: configuration.type, at: url, options: configuration.options)

            if !persistentStoreCoordinator.managedObjectModel.isConfiguration(withName: configuration.name, compatibleWithStoreMetadata: metadata) {
 
                try deleteIfExists(url.path)
                try deleteIfExists("\(url.path)-shm")
                try deleteIfExists("\(url.path)-wal")
            }
        }

        logInfo(tag) { "Attaching persistent store \"\(configuration.url?.absoluteString ?? "nil")\" for type: \(configuration.type)."}

        try persistentStoreCoordinator.addPersistentStore(ofType: configuration.type, configurationName:  configuration.name, at: configuration.url, options: configuration.options)

        logInfo(tag) { "Persistent store attached successfully." }
    }

    fileprivate func deleteIfExists(_ path: String) throws {

        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: path) {
            
            logInfo(tag) { "Removing file \(path)." }
            
            try fileManager.removeItem(atPath: path)
        }
    }
}
