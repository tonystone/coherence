/**
 *   WriteAheadLog.swift
 *
 *   Copyright 2015 Tony Stone
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
 *   Created by Tony Stone on 12/9/15.
 */
import Foundation
import CoreData
import TraceLog

internal enum WriteAheadLogErrors: Error {
    case persistentStoreCreationError(message: String)
    case failedToAddPersistentStore(message: String)
    case failedToObtainPermanentIDs(message: String)
    case transactionWriteFailed(message: String)
}

internal let MetaLogEntryName    = "MetaLogEntry"
internal let persistentStoreType = NSSQLiteStoreType
internal let sqliteFileExts      = ["sqlite", "sqlite-shm", "sqlite-wal"]
internal let metaModel           = MetaModel()

internal class WriteAheadLog {

    fileprivate typealias CoreDataStackType = GenericCoreDataStack<NSPersistentStoreCoordinator, NSManagedObjectContext>
    
    fileprivate let coreDataStack: CoreDataStackType!
    
    var nextSequenceNumber = 0

    init(identifier: String, path: String) throws {
        
        logInfo {
            "Initializing instance..."
        }
        
        coreDataStack = try CoreDataStackType(managedObjectModel: metaModel, storeNamePrefix: "meta", logTag: String(describing: WriteAheadLog.self))
        
        nextSequenceNumber = try self.lastLogEntrySequenceNumber() + 1
        
        logTrace(1) {
            "Starting Transaction ID: \(self.nextSequenceNumber)"
        }
        
        logInfo {
            "Instance initialized."
        }
    }
    
    fileprivate func lastLogEntrySequenceNumber () throws -> Int {
        
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        let metadataContext = coreDataStack.editContext
        
        //
        // We need to find the last log entry and get it's
        // sequenceNumber value to calculate the next number
        // in the database.
        //
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: MetaLogEntryName)
        
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sequenceNumber", ascending:false)]
        
        if let lastLogRecord = try (metadataContext().fetch(fetchRequest).last) as? MetaLogEntry {
            
            return Int(lastLogRecord.sequenceNumber)
        }
        return 0
    }
    
    internal func nextSequenceNumberBlock(_ size: Int) -> ClosedRange<Int> {
        
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        let sequenceNumberBlockStart = nextSequenceNumber

        nextSequenceNumber = nextSequenceNumber + size - 1

        return sequenceNumberBlockStart...size - 1
    }

    internal func logTransactionForContextChanges(_ transactionContext: NSManagedObjectContext) throws -> TransactionID {

        //
        // NOTE: This method must be reentrent.  Be sure to use only stack variables asside from
        //       the protected access method nextSequenceNumberBlock
        //
        let inserted = transactionContext.insertedObjects
        let updated  = transactionContext.updatedObjects
        let deleted  = transactionContext.deletedObjects

        //
        // Get a block of sequence numbers to use for the records
        // that need recording.
        //
        // Sequence number = begin + end + inserted + updated + deleted
        //
        let sequenceNumberBlock = self.nextSequenceNumberBlock(2 + inserted.count + updated.count + deleted.count)
        
        var sequenceNumber = sequenceNumberBlock.lowerBound
        
        var transactionID: TransactionID? = nil
        var writeError: NSError? = nil
        
        let metadataContext = coreDataStack.editContext()
        
        metadataContext.performAndWait {

            do {
                transactionID = try self.logBeginTransactionEntry(metadataContext, sequenceNumber: &sequenceNumber)
                
                if let unwrappedTransactionID = transactionID {
                    
                    self.logInsertEntries(inserted, transactionID: unwrappedTransactionID, metadataContext: metadataContext, sequenceNumber: &sequenceNumber)
                    self.logUpdateEntries(updated,  transactionID: unwrappedTransactionID, metadataContext: metadataContext, sequenceNumber: &sequenceNumber)
                    self.logDeleteEntries(deleted,  transactionID: unwrappedTransactionID, metadataContext: metadataContext, sequenceNumber: &sequenceNumber)
                    
                    try self.logEndTransactionEntry(unwrappedTransactionID, metadataContext: metadataContext, sequenceNumber:  &sequenceNumber)
                    
                    if metadataContext.hasChanges {
                        try metadataContext.save()
                    }
                }
            } catch let error as NSError {
                writeError = error
            }
        }
        
        if let unwrappedWriteError = writeError {
            throw WriteAheadLogErrors.transactionWriteFailed(message: unwrappedWriteError.localizedDescription)
        }
        return transactionID!
    }

    internal func removeTransaction(_ transactionID: TransactionID) {
    }

    internal func transactionLogEntriesForTransaction(_ transactionID: TransactionID, context: NSManagedObjectContext) -> [MetaLogEntry] {
        return []
    }

    internal func transactionLogRecordsForEntity(_ entityDescription: NSEntityDescription, context: NSManagedObjectContext) throws -> [MetaLogEntry] {

        let fetchRequest = NSFetchRequest<NSManagedObject>()

        fetchRequest.entity = NSEntityDescription.entity(forEntityName: MetaLogEntryName, in: context)
        fetchRequest.predicate = NSPredicate(format: "updateEntityName == %@", entityDescription.name!)

        return try context.fetch(fetchRequest) as! [MetaLogEntry]
    }

    fileprivate func logBeginTransactionEntry(_ metadataContext: NSManagedObjectContext, sequenceNumber: inout Int) throws -> TransactionID {

        let metaLogEntry = NSEntityDescription.insertNewObject(forEntityName: MetaLogEntryName, into: metadataContext) as! MetaLogEntry

        do {
            try metadataContext.obtainPermanentIDs(for: [metaLogEntry])

        } catch let error as NSError {
            throw  WriteAheadLogErrors.failedToObtainPermanentIDs(message: "Failed to obtain perminent id for transaction log record: \(error.localizedDescription)")
        }

        //
        // We use the URI representation of the object id as the transactionID
        //
        let transactionID = metaLogEntry.objectID.uriRepresentation().absoluteString

        metaLogEntry.transactionID = transactionID
        metaLogEntry.sequenceNumber = Int32(sequenceNumber)
        metaLogEntry.previousSequenceNumber = Int32(sequenceNumber - 1)
        metaLogEntry.type = MetaLogEntryType.beginMarker
        metaLogEntry.timestamp = Date().timeIntervalSinceNow
        
        //
        // Increment the sequence for this record
        //
        sequenceNumber += 1
        
        logTrace(4) {
            "Log entry created: \(metaLogEntry)"
        }
        
        return transactionID
    }

    fileprivate func logEndTransactionEntry(_ transactionID: TransactionID, metadataContext: NSManagedObjectContext, sequenceNumber: inout Int) throws {

        let metaLogEntry = NSEntityDescription.insertNewObject(forEntityName: MetaLogEntryName, into: metadataContext) as! MetaLogEntry

        metaLogEntry.transactionID = transactionID
        metaLogEntry.sequenceNumber = Int32(sequenceNumber)
        metaLogEntry.previousSequenceNumber = Int32(sequenceNumber - 1)
        metaLogEntry.type = MetaLogEntryType.endMarker
        metaLogEntry.timestamp = Date().timeIntervalSinceNow
        
        //
        // Increment the sequence for this record
        //
        sequenceNumber += 1
        
        logTrace(4) {
            "Log entry created: \(metaLogEntry)"
        }
    }
    
    fileprivate func logInsertEntries(_ insertedRecords: Set<NSManagedObject>, transactionID: TransactionID, metadataContext: NSManagedObjectContext,  sequenceNumber: inout Int) {
        
        for object in insertedRecords {

            let metaLogEntry = self.transactionLogEntry(MetaLogEntryType.insert, object: object, transactionID: transactionID, metadataContext: metadataContext, sequenceNumber: sequenceNumber)
            //
            // Get the object attribute change data
            //
            let data = MetaLogEntry.MetaLogEntryInsertData()

            let attributes = [String](object.entity.attributesByName.keys)
            
            data.attributesAndValues = object.dictionaryWithValues(forKeys: attributes) as [String : AnyObject]

            metaLogEntry.updateData = data
            
            //
            // Increment the sequence for this record
            //
            sequenceNumber += 1
            
            logTrace(4) {
                "Log entry created: \(metaLogEntry)"
            }
        }
    }
    
    fileprivate func logUpdateEntries(_ updatedRecords: Set<NSManagedObject>, transactionID: TransactionID, metadataContext: NSManagedObjectContext, sequenceNumber: inout Int) {
        
        for object in updatedRecords {
            
            let metaLogEntry = self.transactionLogEntry(MetaLogEntryType.update, object: object, transactionID: transactionID, metadataContext: metadataContext, sequenceNumber: sequenceNumber)
            //
            // Get the object attribute change data
            //
            let data = MetaLogEntry.MetaLogEntryUpdateData()

            let attributes = [String](object.entity.attributesByName.keys)
            
            data.attributesAndValues = object.dictionaryWithValues(forKeys: attributes) as [String : AnyObject]
            data.updatedAttributes   = [String](object.changedValues().keys)

            metaLogEntry.updateData = data

            //
            // Increment the sequence for this record
            //
            sequenceNumber += 1
            
            logTrace(4) {
                "Log entry created: \(metaLogEntry)"
            }
        }
    }

    fileprivate func logDeleteEntries(_ deletedRecords: Set<NSManagedObject>, transactionID: TransactionID, metadataContext: NSManagedObjectContext, sequenceNumber: inout Int) {
        
        for object in deletedRecords {

            let metaLogEntry = self.transactionLogEntry(MetaLogEntryType.delete, object: object, transactionID: transactionID, metadataContext: metadataContext, sequenceNumber: sequenceNumber)
           
            //
            // Increment the sequence for this record
            //
            sequenceNumber += 1
            
            logTrace(4) {
                "Log entry created: \(metaLogEntry)"
            }
        }
    }

    fileprivate func transactionLogEntry(_ type: MetaLogEntryType, object: NSManagedObject, transactionID: TransactionID, metadataContext: NSManagedObjectContext, sequenceNumber: Int) -> MetaLogEntry {

        let metaLogEntry = NSEntityDescription.insertNewObject(forEntityName: MetaLogEntryName, into: metadataContext) as! MetaLogEntry

        metaLogEntry.transactionID = transactionID
        metaLogEntry.sequenceNumber = Int32(sequenceNumber)
        metaLogEntry.previousSequenceNumber = Int32(sequenceNumber - 1)
        metaLogEntry.type = MetaLogEntryType.endMarker
        metaLogEntry.timestamp = Date().timeIntervalSinceNow
        
        //
        // Update the object identification data
        //
        metaLogEntry.updateObjectID = object.objectID.uriRepresentation().absoluteString
        metaLogEntry.updateEntityName = object.entity.name

        return metaLogEntry
    }
}
