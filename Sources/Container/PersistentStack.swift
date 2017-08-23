///
///  PersistentStack.swift
///
///  Copyright 2017 Tony Stone
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
///  Created by Tony Stone on 4/1/17.
///
import Swift
import CoreData

public protocol PersistentStack {

    ///
    /// Creates and returns a URL to the default directory for the persistent stores.
    ///
    static func defaultStoreLocation() -> URL

    ///
    /// The name of this instance.
    ///
    var name: String { get }

    ///
    /// The model this instance was constructed with.
    ///
    var managedObjectModel: NSManagedObjectModel { get }

    ///
    /// Returns the `NSPersistentStoreCoordinate` that
    /// this instance contains.
    ///
    var persistentStoreCoordinator: NSPersistentStoreCoordinator { get }

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
    func attachPersistentStore(at url: URL, for configuration: StoreConfiguration) throws -> NSPersistentStore

    ///
    /// Detach a persistent store from the Coordinator.
    ///
    func detach(persistentStore: NSPersistentStore) throws

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
    func attachPersistentStores(at url: URL, for configurations: [StoreConfiguration]) throws -> [NSPersistentStore]

    ///
    /// Detach a persistent stores from the Coordinator.
    ///
    func detach(persistentStores: [NSPersistentStore]) throws

    ///
    /// The main context.
    ///
    /// This context should be used for read operations only.  Use it for all fetches and NSFetchedResultsControllers.
    ///
    var viewContext: NSManagedObjectContext { get }

    ///
    /// Gets a new NSManagedObjectContext that can be used for updating objects.
    ///
    /// At save time, Connect will merge those changes back to the viewContext.
    ///
    /// - Note: This method and the returned `BackgroundContext` can be used on a background thread.  It can also be used on the main thread.
    ///
    func newBackgroundContext() -> BackgroundContext

}

///
/// Creates and returns a URL to the default directory for the persistent stores.
///
private func defaultStoreLocation() -> URL {
    return abortIfError(block: { try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) })
}

extension PersistentStack {

    ///
    /// Creates and returns a URL to the default directory for the persistent stores.
    ///
    public static func defaultStoreLocation() -> URL {
        return Coherence.defaultStoreLocation()
    }

    ///
    /// The model this instance was constructed with.
    ///
    public var managedObjectModel: NSManagedObjectModel {
        return persistentStoreCoordinator.managedObjectModel
    }

    @discardableResult
    public func attachPersistentStores(at url: URL = defaultStoreLocation(), for configurations: [StoreConfiguration] = [StoreConfiguration()]) throws -> [NSPersistentStore] {
        return try attachPersistentStores(at: url, for: configurations)
    }

    @discardableResult
    public func attachPersistentStore(at url: URL = defaultStoreLocation(), for configuration: StoreConfiguration = StoreConfiguration()) throws -> NSPersistentStore {
        return try attachPersistentStore(at: url, for: configuration)
    }
}
