///
///  PersistentStack.swift
///  Pods
///
///  Created by Tony Stone on 4/1/17.
///
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
    /// The persistent store configurations used to create the persistent stores referenced by this instance.
    ///
    var storeConfigurations: [StoreConfiguration] { get set }

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
    /// The main context.
    ///
    /// This context should be used for read operations only.  Use it for all fetches and NSFetchedResultsControllers.
    ///
    /// It will be maintained automatically and be kept consistent.
    ///
    /// - Warning: You should only use this context on the main thread.  If you must work on a background thread, use the method `newBackgroundContext` while on the thread.  See that method for more details
    ///
    var viewContext: NSManagedObjectContext { get }

    ///
    /// Gets a new NSManagedObjectContext that can be used for updating objects.
    ///
    /// At save time, Connect will merge those changes back to the viewContext.
    ///
    /// - Note: This method and the returned NSManagedObjectContext can be used on a background thread as long as you get the context while on that thread.  It can also be used on the main thread if gotten while on the main thread.
    ///
    func newBackgroundContext() -> NSManagedObjectContext
}

extension PersistentStack {

    ///
    /// Creates and returns a URL to the default directory for the persistent stores.
    ///
    public static func defaultStoreLocation() -> URL {
        return abortIfError(block: { try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) })
    }
}
