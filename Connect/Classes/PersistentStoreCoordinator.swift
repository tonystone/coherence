/*
 *   PersistentStoreCoordinator.swift
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
 *   Created by Tony Stone on 8/21/16.
 */
import Foundation
import TraceLog
import CoreData

// FIXME: Remove this once you have a better solution for naming the log
internal extension NSManagedObjectModel {

    internal func uniqueIdentifier() -> String {
        //
        // Calculate the hash of the Models entityVersionHashes
        //
        var hash = 0;

        for entityHash in self.entityVersionHashesByName.values {
            hash = 31 &* hash &+ entityHash.hash;
        }
        return String(hash);
    }
}

private struct Flags {
    var managed:      Bool = true
    var synchronized: Bool   = false
}

public class PersistentStoreCoordinator : NSPersistentStoreCoordinator {

    private typealias ActionQueuesType =  [NSEntityDescription : ActionQueue]
    
    // Initialize the flags with the default values
    private let flags: Flags = Flags()
    private let entityQueues: ActionQueuesType
    
    // The internal write ahead log for logging transactions
    private let writeAheadLog: WriteAheadLog?
    
    public override convenience init(managedObjectModel model: NSManagedObjectModel) {
        self.init(managedObjectModel: model, enableLogging: true)
    }

    public init(managedObjectModel model: NSManagedObjectModel, enableLogging: Bool) {

        logInfo { "Initializing instance..." }

        if enableLogging {
            //
            // Figure out where to put things
            //
            let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]

            //
            // Create our write ahead logger
            //
            do {
                writeAheadLog = try WriteAheadLog(identifier: model.uniqueIdentifier(), path: cachePath)
            } catch {
                writeAheadLog = nil

                logError { "Failed to enable logging." }
            }
        } else {
            writeAheadLog = nil

            logInfo { "Logging is disabled." }
        }
        
        // Initialize the entity queues, 1 per entity listed in the model.
        var queues = ActionQueuesType()
        
        for entity in model.entities {
            if let entityName = entity.name {
                queues[entity] = ActionQueue(name: "connect.entityqueue.\(entityName)", concurrencyMode: .serial)
                
                entity.managed = true
            } else {
                logWarning {
                    "Entity \(entity) does not have a name and will not be managed."
                }
                entity.managed = false
            }
        }
        self.entityQueues = queues
        
        super.init(managedObjectModel: model)

        logInfo { "Instance initialized." }
    }

    public override func addPersistentStoreWithType(storeType: String, configuration: String?, URL storeURL: NSURL?, options: [NSObject:AnyObject]?) throws -> NSPersistentStore {

        if flags.managed {
            logInfo {
                var message = "Attaching persistent store of type \"\(storeType)\""

                if let path = storeURL?.absoluteString {
                    message = message + " at path: \(path)"
                } else {
                    message = message + "."
                }
                return message
            }
        }
        return try super.addPersistentStoreWithType(storeType, configuration: configuration, URL: storeURL, options: options)
    }

    public override func removePersistentStore(store: NSPersistentStore) throws {

        if flags.managed {
            logInfo {
                var message = "Removing persistent store of type \"\(store.type)\""

                if let path = store.URL?.absoluteString {
                    message = message + " at path: \(path)"
                } else {
                    message = message + "."
                }
                return message
            }
        }

        try super.removePersistentStore(store)
    }

    public override func executeRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext) throws -> AnyObject {

        switch (request.requestType) {

        case NSPersistentStoreRequestType.SaveRequestType: fallthrough
        case NSPersistentStoreRequestType.BatchUpdateRequestType:

            if let log = self.writeAheadLog {

                //
                // Obtain permanent IDs for all inserted objects
                //
                try context.obtainPermanentIDsForObjects([NSManagedObject](context.insertedObjects))

                //
                // Log the changes from the context in a transaction
                //
                let transactionID = try log.logTransactionForContextChanges(context)

                //
                // Save the main context
                //
                do {
                    let results = try super.executeRequest(request, withContext:context)

                    return results;
                } catch {
                    log.removeTransaction(transactionID)

                    throw error
                }
            } else {
                fallthrough
            }
        case NSPersistentStoreRequestType.FetchRequestType: fallthrough
        default:
            return try super.executeRequest(request, withContext:context)
        }
    }
}

//
// Initialize the system
//
extension  PersistentStoreCoordinator {

     public override class func initialize() {

        // make sure this isn't a subclass
        if self !== PersistentStoreCoordinator.self {
            return
        }

         struct Static {
             static var token: dispatch_once_t = 0
         }

         dispatch_once(&Static.token) {

            logInfo { "Initializing CoreData Extensions..." }
            
            
            logInfo { "CoreData Extensions initialized" }
            
         }
    }
}
