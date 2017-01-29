///
///  Connect.swift
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
///  Created by Tony Stone on 3/26/13.
///  Rewriten by Tony Stone on 1/28/17.
///
import CoreData
import TraceLog
import UIKit

///
/// The extension of the store bundle created for this store.
///
private let connectBundleExtension: String = "connect"

///
/// Location to store the connect store bundle.
///
private let connectBundleDirectory: FileManager.SearchPathDirectory = .documentDirectory

///
/// Connect
///
/// Manages all resources from threads to web services
///
public class Connect {

    /// 
    /// Errors thrown from Connect
    ///
    public enum Errors: Error {
        case unmanagedEntity(String)
    }

    ///
    /// Internal types defining the MetaCache and DataCache CoreDataStack types
    ///
    fileprivate typealias MetaCacheType = GenericCoreDataStack<NSPersistentStoreCoordinator, NSManagedObjectContext>
    fileprivate typealias DataCacheType = GenericCoreDataStack<ConnectCoordinator, NSManagedObjectContext>

    ///
    /// Stack used to manage meta data about the main cache
    ///
    fileprivate let metaCache: MetaCacheType

    ///
    /// Main user cache stack
    ///
    fileprivate let dataCache: DataCacheType

    ///
    /// The internal write ahead log for logging transactions
    ///
    fileprivate var writeAheadLog: WriteAheadLog? = nil

    ///
    /// Action notification service used by action containers
    ///
    fileprivate let actionNotificationService: ActionNotificationService

    ///
    /// Generic queue used for executing `GenericAction` types.
    ///
    fileprivate var genericQueue: ActionQueue

    ///
    /// Isolation queues used for executing `EntityAction` types.
    ///
    fileprivate var entityQueues: [String: ActionQueue] = [:]

    ///
    /// Tag used for all logging internally
    ///
    fileprivate var logTag = String(describing: Connect.self)

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
    public var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        return self.dataCache.persistentStoreCoordinator
    }

    ///
    /// Internal class to create the connect bundle.
    ///
    /// - Note: you can not use a func on self for this
    ///         since we are initializing a content in self.
    ///
    private class BundleManager {

        class func createIfAbsent(bundleName: String, in directory: FileManager.SearchPathDirectory) throws -> URL {

            //
            // Figure out where to put things
            //
            // Note: We use the applications bundle not the classes or modules.
            //
            let baseURL = try FileManager.default.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: false)

            ///
            /// The individual stores are stored in a directory with the extension of connect.
            ///
            /// Example: "HR.connect"
            ///
            let bundleURL = baseURL.appendingPathComponent("\(bundleName).\(connectBundleExtension)", isDirectory: true)

            ///
            /// create direcotry will throw if the directory can't be created.  If it already exists, it will simply return.
            ///
            try FileManager.default.createDirectory(at: bundleURL, withIntermediateDirectories: true, attributes: nil)
            
            return bundleURL
        }
    }

    ///
    ///  Initializes the receiver with a managed object model.
    ///
    ///   - parameters:
    ///      - managedObjectModel: A managed object model.
    ///      - configurationOptions: Optional configuration settings by persistent store config name (see ConfigurationOptionsType for structure)
    ///      - storeNamePrefix: An optional String which is appended to the beginning of the persistent store's name.
    ///
    public init(managedObjectModel model: NSManagedObjectModel, storeName: String, configurationOptions options: ConfigurationOptionsType = defaultConfigurationOptions) throws {

        logInfo { "Initializing instance..." }

        self.managedObjectModel = model

        let bundleURL = try BundleManager.createIfAbsent(bundleName: storeName, in: connectBundleDirectory)

        logInfo { "Creating the user data cache...." }

        self.dataCache = try DataCacheType(managedObjectModel: model, storeLocationURL: bundleURL, configurationOptions: options, asyncErrorBlock: nil, logTag: logTag)

        logInfo { "Creating the meta data cache...." }

        self.metaCache = try MetaCacheType(managedObjectModel: MetaModel(), storeLocationURL: bundleURL, logTag: logTag)

        logInfo { "Creating action notification service..." }

        self.actionNotificationService = ActionNotificationService()

        logInfo { "Creating generic queue..." }

        self.genericQueue = ActionQueue(name: "connect.entity.queue.generic", concurrencyMode: .concurrent)

        ///
        /// Initialize the entities
        ///
        for (name, entity) in model.entitiesByName {

            logInfo { "Found entity '\(name)'." }

            self.manage(name: name, entity: entity)
        }

        self.registerForNotifications()

        logInfo { "Instance initialized." }
    }

    deinit {
        self.unregisterForNotifications()
    }
}

///
/// Action Execution methods
///
public extension Connect {

    func execute<ActionType: GenericAction>(_ action: ActionType, completionBlock: ((_ actionProxy: ActionProxy) -> Void)?) throws -> ActionProxy {

        let container = GenericActionContainer<ActionType>(action: action, notificationService: self.actionNotificationService, completionBlock: completionBlock)

        logTrace(1) { "Queuing \(container) on queue `\(self.genericQueue)'" }

        self.genericQueue.addAction(container, waitUntilDone: false)

        return container
    }

    func execute<ActionType: EntityAction>(_ action: ActionType, completionBlock: ((_ actionProxy: ActionProxy) -> Void)?) throws -> ActionProxy {

        let entityQueue = try queue(entity: ActionType.EntityType.self)

        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.dataCache.persistentStoreCoordinator

        let container = EntityActionContainer<ActionType>(action: action, context: context, notificationService: self.actionNotificationService, completionBlock: completionBlock)

        logTrace(1) { "Queuing \(container) on queue `\(entityQueue)'" }

        entityQueue.addAction(container, waitUntilDone: false)

        return container
    }
}

///
/// Connect state management
///
public extension Connect {

    public func start() {

    }

    public func stop() {

    }

    public var online: Bool {
        return true
    }
}

///
/// Connect Notification handling
///
private extension Connect {

    func registerForNotifications() {

    }

    func unregisterForNotifications() {

    }

    func handleProtectedDataWillBecomeUnavailable(notification: NSNotification) {

    }

    func handleProtectedDataDidBecomeAvailable(notification: NSNotification) {

    }

    func handleApplicationWillTerminate(notification: NSNotification) {

    }

    func handleApplicationDidEnterBackground(notification: NSNotification) {

    }

    func handleApplicationWillEnterForeground(notification: NSNotification) {

    }

    func handleConnectivityChanged(notification: NSNotification) {

    }
}

///
/// Utility methods
///
fileprivate extension Connect {

    func manage(name: String, entity: NSEntityDescription) -> Bool {
        logInfo { "Determining if entity '\(name)' can be managed...."}

        var canBeManaged = true

        if let userInfo = entity.userInfo, userInfo.count > 0 {
            logInfo { "UserInfo found on entity '\(name)', reading static settings (if any)." }
            entity.setSettings(from: userInfo)
        }

        if let uniquenessAttributes = entity.uniquenessAttributes {
            var valid = true

            for attribute in uniquenessAttributes {
                if !entity.attributesByName.keys.contains(attribute) {
                    valid = false

                    logWarning { "Uniqueness attribute '\(attribute)' specified but it is not present on entity." }
                    break
                }
            }

            if !valid {
                canBeManaged = false

                logWarning { "Setting value '\(uniquenessAttributes)' for 'uniquenessAttributes' invalid." }
            }

        } else {

            if #available(iOS 9.0, *), entity.uniquenessConstraints.count > 0 {

                logInfo { "Found constraints, using the least complex key for 'uniquenessAttributes'.  To override define 'uniquenessAttributes' in your CoreData model for entity '\(name)'."}

                var shortest = entity.uniquenessConstraints[0]

                for attributes in entity.uniquenessConstraints {
                    if attributes.count < shortest.count {
                        shortest = attributes
                    }
                }

                entity.uniquenessAttributes = {
                    var array: [String] = []

                    for case let attribute as NSAttributeDescription in shortest {
                        array.append(attribute.name)
                    }
                    return array
                }()

            } else {
                canBeManaged = false

                logInfo { "Missing 'uniquenessAttributes' setting."}
            }
        }

        if canBeManaged {

            let queueName = "connect.entity.queue.\(name.lowercased())"

            logInfo { "Creating action queue for entity '\(name)' (\(queueName))" }

            self.entityQueues[name] = ActionQueue(name: queueName, concurrencyMode: .serial)

            entity.managed = true

            logInfo { "Entity '\(name)' marked as managed."}
        } else {

            logInfo { "Entity '\(name)' cannot be managed."}
        }

        return entity.managed
    }

    func queue<EntityType: NSManagedObject>(entity: EntityType.Type) throws -> ActionQueue {
        let entityName = String(describing: entity)

        guard let queue = self.entityQueues[entityName] else {
            throw Errors.unmanagedEntity("Entity '\(entityName)' not managed by \(self)")
        }
        return queue
    }
}
