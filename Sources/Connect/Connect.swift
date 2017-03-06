///
///  Connect.swift
///
///  Copyright 2013 Tony Stone
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
    /// The name of this instance of Connect
    ///
    public let name: String

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
    /// The model this `GenericCoreDataStack` was constructed with.
    ///
    public var managedObjectModel: NSManagedObjectModel {
        return self.persistentStoreCoordinator.managedObjectModel
    }

    ///
    /// Internal types defining the MetaCache and DataCache CoreDataStack types
    ///
    fileprivate typealias MetaCacheType = GenericCoreDataStack<NSPersistentStoreCoordinator, NSManagedObjectContext, NSManagedObjectContext>
    fileprivate typealias DataCacheType = GenericCoreDataStack<ConnectCoordinator, NSManagedObjectContext, LoggingContext>

    ///
    /// Stack used to manage meta data about the main cache
    ///
    fileprivate let metaCache: MetaCacheType

    ///
    /// Main user cache stack
    ///
    fileprivate let dataCache: DataCacheType

    ///
    /// Notification service used by action containers and other services that post notifications.
    ///
    fileprivate let notificationService: NotificationService

    ///
    /// The internal write ahead log for logging transactions
    ///
    fileprivate var writeAheadLog: WriteAheadLog?

    ///
    /// Generic queue used for executing `GenericAction` types.
    ///
    fileprivate var genericQueue: ActionQueue

    ///
    /// Isolation queues used for executing `EntityAction` types.
    ///
    fileprivate var entityQueues: [String: ActionQueue]

    ///
    /// Background syncrhonization queue for synchronizing
    /// operations on `Connect`.
    ///
    fileprivate let synchronizationQueue: DispatchQueue

    ///
    /// Tag used for all logging internally
    ///
    fileprivate var logTag = String(describing: Connect.self)

    ///
    /// Configuraiton option used to start the dataCache.
    ///
    fileprivate let dataCacheOptions: ConfigurationOptionsType

    ///
    /// Configuraiton option used to start the metaCache.
    ///
    fileprivate let metaCacheOptions: ConfigurationOptionsType

    ///
    /// Was this instance already started?
    ///
    fileprivate var started: Bool

    ///
    ///  Initializes the receiver with a managed object model.
    ///
    ///   - parameters:
    ///      - name: the name used for this instance of connect, this name will be used to name the persistent store files on disk.
    ///
    public convenience init(name: String, configurationOptions options: ConfigurationOptionsType = defaultConfigurationOptions) {

        let url = abortIfNil(message: "Could not locate model `\(name)` in any bundle.") {
            return Bundle.url(forManagedObjectModelName: name)
        }

        let model = abortIfNil(message: "Failed to load model at \(url).") {
            return NSManagedObjectModel(contentsOf: url)
        }
        self.init(name: name, managedObjectModel: model, configurationOptions: options)
    }

    ///
    ///  Initializes the receiver with a managed object model.
    ///
    ///   - parameters:
    ///      - managedObjectModel: A managed object model.
    ///      - configurationOptions: Optional configuration settings by persistent store config name (see ConfigurationOptionsType for structure)
    ///      - storeNamePrefix: An optional String which is appended to the beginning of the persistent store's name.
    ///
    public required init(name: String, managedObjectModel model: NSManagedObjectModel, configurationOptions options: ConfigurationOptionsType = defaultConfigurationOptions) {

        self.name             = name
        self.dataCacheOptions = options
        self.metaCacheOptions = defaultConfigurationOptions

        self.dataCache = DataCacheType(name: "", managedObjectModel: model,       logTag: logTag)
        self.metaCache = MetaCacheType(name: "", managedObjectModel: MetaModel(), logTag: logTag)

        self.notificationService = NotificationService()

        self.genericQueue = ActionQueue(name: "connect.action.queue", concurrencyMode: .concurrent)
        self.entityQueues = [:]
        ///
        /// Serial queue with background priority
        ///
        self.synchronizationQueue = DispatchQueue(label: "connect.synchronization.queue", qos: .background)

        self.started = false

        ///
        /// Note: due to Swift requirement for not passing self until all instance
        ///       variables have a value, this has to be set here and not in the 
        ///       init method of the NotificationService.
        ///
        self.notificationService.source = self
    }

    deinit {
        self.unregisterForNotifications()
    }
}

///
/// Connect CoreDataStack implementation
///
extension Connect: CoreDataStack {

    public var viewContext: NSManagedObjectContext {
        return self.dataCache.viewContext
    }

    public func newBackgroundContext() -> NSManagedObjectContext {
        return self.newBackgroundContext(logged: true)
    }

    public func newBackgroundContext(logged: Bool) -> NSManagedObjectContext {

        let context = self.dataCache.newBackgroundContext()

        if logged {
            ///
            /// Attached the logger to the context
            /// so updates can be looged.
            ///
            context.logger = self.writeAheadLog
        }
        return context
    }

    internal func newActionContext() -> ActionContext {

        let context = ActionContext(concurrencyType: .privateQueueConcurrencyType)
        
        context.persistentStoreCoordinator = self.dataCache.persistentStoreCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.logger = self.writeAheadLog

        return context
    }
}

///
/// Action Execution methods
///
public extension Connect {

    @discardableResult
    func execute<ActionType: GenericAction>(_ action: ActionType, completionBlock: ((_ actionProxy: ActionProxy) -> Void)? = nil) throws -> ActionProxy {

        let container = GenericActionContainer<ActionType>(action: action, notificationService: self.notificationService, completionBlock: completionBlock)

        logInfo { "Queuing \(container) on queue `\(self.genericQueue)'" }

        self.genericQueue.addAction(container, waitUntilDone: false)

        return container
    }

    @discardableResult
    func execute<ActionType: EntityAction>(_ action: ActionType, completionBlock: ((_ actionProxy: ActionProxy) -> Void)? = nil) throws -> ActionProxy {

        let entityQueue = try queue(entity: ActionType.ManagedObjectType.self)

        let context = self.newActionContext()

        let container = EntityActionContainer<ActionType>(action: action, context: context, notificationService: self.notificationService, completionBlock: completionBlock)

        logInfo { "Queuing \(container) on queue `\(entityQueue)'" }

        entityQueue.addAction(container, waitUntilDone: false)

        return container
    }
}

///
/// Connect state management
///
public extension Connect {

    ///
    /// Asynchronously start the instance of `Connect`
    ///
    public func start(completionBlock: @escaping (Error?) -> Void) {

        self.synchronizationQueue.async {
            do {
                try self._start()

                completionBlock(nil)
            } catch {
                completionBlock(error)
            }
        }
    }

    ///
    /// Synchronously start the instance of `Connect`
    ///
    public func start() throws {

        try self.synchronizationQueue.sync {
            try self._start()
        }
    }

    private func _start() throws {

        guard !started else {
            return
        }

        try autoreleasepool {

            logInfo { "Starting instance '\(self.name)'..." }

            logInfo { "Loading persistent stores..." }

            let bundleURL = try BundleManager.createIfAbsent(bundleName: name, in: connectBundleDirectory)

            try self.dataCache.loadPersistentStores(storeLocationURL: bundleURL, configurationOptions: dataCacheOptions)
            try self.metaCache.loadPersistentStores(storeLocationURL: bundleURL, configurationOptions: metaCacheOptions)

            logInfo { "Creating the write ahead log..." }

            self.writeAheadLog = try WriteAheadLog(coreDataStack: self.metaCache)

            ///
            /// Initialize the entities
            ///
            for (name, entity) in self.dataCache.managedObjectModel.entitiesByName {

                logInfo { "Found entity '\(name)'." }

                self.manage(name: name, entity: entity)
            }

            self.registerForNotifications()

            self.started = true

            logInfo { "Instance initialized." }
        }
    }

    public var online: Bool {
        return true
    }
}

///
/// Connect Notification handling
///
fileprivate extension Connect {

    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleProtectedDataDidBecomeAvailable(notification:)),     name: Foundation.Notification.Name.UIApplicationProtectedDataDidBecomeAvailable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleProtectedDataWillBecomeUnavailable(notification:)),  name: Foundation.Notification.Name.UIApplicationProtectedDataWillBecomeUnavailable, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidEnterBackground(notification:)),       name: Foundation.Notification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationWillEnterForeground(notification:)),      name: Foundation.Notification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationWillTerminate(notification:)),            name: Foundation.Notification.Name.UIApplicationWillTerminate, object: nil)

    }

    func unregisterForNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    dynamic func handleProtectedDataDidBecomeAvailable(notification: NSNotification) {

    }

    dynamic func handleProtectedDataWillBecomeUnavailable(notification: NSNotification) {

    }

    dynamic func handleApplicationDidEnterBackground(notification: NSNotification) {

    }

    dynamic func handleApplicationWillEnterForeground(notification: NSNotification) {
        
    }

    dynamic func handleApplicationWillTerminate(notification: NSNotification) {

    }

    dynamic func handleConnectivityChanged(notification: NSNotification) {

    }
}

///
/// Utility methods
///
fileprivate extension Connect {

    @discardableResult
    func manage(name: String, entity: NSEntityDescription) -> Bool {
        logInfo { "Determining if entity '\(name)' can be managed...."}

        var canBeManaged = true

        if let userInfo = entity.userInfo, userInfo.count > 0 {
            logInfo { "UserInfo found on entity '\(name)', reading static settings (if any)." }
            entity.setSettings(from: userInfo)
        }

        if !entity.uniquenessAttributes.isEmpty {
            var valid = true

            for attribute in entity.uniquenessAttributes {
                if !entity.attributesByName.keys.contains(attribute) {
                    valid = false

                    logWarning { "Uniqueness attribute '\(attribute)' specified but it is not present on entity." }
                    break
                }
            }

            if !valid {
                canBeManaged = false

                logWarning { "Setting value '\(entity.uniquenessAttributes)' for 'uniquenessAttributes' invalid." }
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

            let queueName = "connect.action.queue.\(name.lowercased())"

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

fileprivate extension Connect {

    ///
    /// Internal class to create the connect bundle.
    ///
    /// - Note: you can not use a func on self for this
    ///         since we are initializing a content in self.
    ///
    fileprivate class BundleManager {

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
}
