///
///  PersistentStoreCoordinator.swift
///
///  Copyright 2015 Tony Stone
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
///  Created by Tony Stone on 12/8/15.
///
import Foundation
import CoreData
import TraceLog

open class PersistentStoreCoordinator : NSPersistentStoreCoordinator {

    enum Errors: Error {
        case unmanagedEntity(String)
    }

    // The internal write ahead log for logging transactions
    fileprivate var writeAheadLog: WriteAheadLog? = nil
    fileprivate let actionNotificationService: ActionNotificationService

    fileprivate var genericQueue: ActionQueue
    fileprivate var entityQueues: [String: ActionQueue] = [:]

    override public convenience init(managedObjectModel model: NSManagedObjectModel) {
        self.init(managedObjectModel: model, enableLogging: true)
    }
    
    public init(managedObjectModel model: NSManagedObjectModel, enableLogging: Bool) {

        logInfo { "Initializing instance..." }

        logInfo { "Creating action notification service..." }

        self.actionNotificationService = ActionNotificationService()

        logInfo { "Creating generic queue..." }

        self.genericQueue = ActionQueue(name: "connect.entity.queue.generic", concurrencyMode: .concurrent)

        ///
        /// Now that all of our local vaeriables are assigned, we
        /// must call super init so we can use our variables 
        /// from this point on.
        ///
        super.init(managedObjectModel: model)

        ///
        /// Initialize the entities
        ///
        for (name, entity) in model.entitiesByName {

            logInfo { "Found entity '\(name)'." }

            self.manage(name: name, entity: entity)
        }

        if enableLogging {

            logInfo { "Logging enabled, creating write ahead log..." }

            //
            // Figure out where to put things
            //
            let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            
            //
            // Create our write ahead logger
            //
            do {
                writeAheadLog = try WriteAheadLog(identifier: model.uniqueIdentifier(), path: cachePath)
            } catch {
                logError { "Failed to enable logging." }
            }
        } else {
            logInfo { "Logging is disabled." }
        }

        logInfo { "Instance initialized." }
    }
    
    override open func addPersistentStore(ofType storeType: String, configurationName configuration: String?, at storeURL: URL?, options: [AnyHashable: Any]?) throws -> NSPersistentStore {
        
        logInfo {
            "Attaching persistent store for type: \(storeType) at path: \(storeURL?.absoluteString)..."
        }
        var persistentStore: NSPersistentStore? = nil;
        
        do {
            persistentStore = try super.addPersistentStore(ofType: storeType, configurationName: configuration, at: storeURL, options: options)
        
            logInfo { "Persistent Store attached." }

        } catch let error as NSError {
            logError { "Failed to attach persistent store: \(error.localizedDescription)" }
            
            throw error
        }
        return persistentStore!
    }
    
    override open func remove(_ store: NSPersistentStore) throws {
        logInfo { "Removing persistent store for type: \(store.type) at path: \(store.url)..." }
        
        try super.remove(store)

        logInfo { "Persistent Store removed." }
    }
    
    override open func execute(_ request: NSPersistentStoreRequest, with context: NSManagedObjectContext) throws -> Any {
        
        switch (request.requestType) {
            
        case NSPersistentStoreRequestType.saveRequestType: fallthrough
        case NSPersistentStoreRequestType.batchUpdateRequestType:
            
            if let log = self.writeAheadLog {
                
                //
                // Obtain permanent IDs for all inserted objects
                //
                try context.obtainPermanentIDs(for: [NSManagedObject](context.insertedObjects))
                
                //
                // Log the changes from the context in a transaction
                //
                let transactionID = try log.logTransactionForContextChanges(context)
                
                //
                // Save the main context
                //
                do {
                    let results = try super.execute(request, with:context)
                    
                    return results;
                } catch {
                    log.removeTransaction(transactionID)
                    
                    throw error
                }
            } else {
                fallthrough
            }
        case NSPersistentStoreRequestType.fetchRequestType: fallthrough
        default:
            return try super.execute(request, with:context)
        }
    }
}

///
/// Action Execution methods
///
public extension PersistentStoreCoordinator {

    func execute<ActionType: GenericAction>(_ action: ActionType, completionBlock: ((_ actionProxy: ActionProxy) -> Void)?) throws -> ActionProxy {

        let container = GenericActionContainer<ActionType>(action: action, notificationService: self.actionNotificationService, completionBlock: completionBlock)

        logTrace(1) { "Queuing \(container) on queue `\(self.genericQueue)'" }

        self.genericQueue.addAction(container, waitUntilDone: false)

        return container
    }

    func execute<ActionType: EntityAction>(_ action: ActionType, completionBlock: ((_ actionProxy: ActionProxy) -> Void)?) throws -> ActionProxy {

        let entityQueue = try queue(entity: ActionType.EntityType.self)

        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self

        let container = EntityActionContainer<ActionType>(action: action, context: context, notificationService: self.actionNotificationService, completionBlock: completionBlock)

        logTrace(1) { "Queuing \(container) on queue `\(entityQueue)'" }

        entityQueue.addAction(container, waitUntilDone: false)

        return container
    }
}

///
/// Utility methods
///
fileprivate extension PersistentStoreCoordinator {

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

fileprivate extension NSManagedObjectModel {

    func uniqueIdentifier() -> String {
        //
        // Calculate the hash of the Models entityVersionHashes
        //
        var hash = 0;

        for entityHash in self.entityVersionHashesByName.values {
            hash = 31 &* hash &+ (entityHash as NSData).hash;
        }
        return String(hash);
    }

}

