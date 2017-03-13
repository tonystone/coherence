///
///  WriteAheadLogTests.swift
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
///  Created by Tony Stone on 3/7/17.
///
import XCTest
import CoreData

@testable import Coherence

class WriteAheadLogTests: XCTestCase {

    typealias CoreDataStackType = GenericCoreDataStack<NSPersistentStoreCoordinator, NSManagedObjectContext, NSManagedObjectContext>

    override func setUp() {
        super.setUp()

        do {
            try removePersistentStoreCache()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    override func tearDown() {
        do {
            try removePersistentStoreCache()
        } catch {
            XCTFail(error.localizedDescription)
        }
        super.tearDown()
    }

    func testInit() {

        let input = CoreDataStackType(name: "MetaModel", managedObjectModel: MetaModel())
        let expected: ClosedRange<Int> = 1...1

        do {
            let log = try WriteAheadLog(coreDataStack: input)

            XCTAssertEqual(log.nextSequenceNumberBlock(1), expected)
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }

    func testInitFailedToFindMetaLogEntity() {

        let input = CoreDataStackType(name: "MetaModel", managedObjectModel: NSManagedObjectModel())

        do {
            try input.loadPersistentStores()

            XCTAssertThrowsError(try WriteAheadLog(coreDataStack: input))
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }

    func testLastLogEntrySequenceNumber() {

        let input = CoreDataStackType(name: "MetaModel", managedObjectModel: MetaModel())
        let expected: ClosedRange<Int> = 5...5

        do {
            try input.loadPersistentStores()

            /// prime the database with mock records
            let context = input.newBackgroundContext()

            try context.performAndWait {

                for index in 0..<5 {
                    guard let logEntry = NSEntityDescription.insertNewObject(forEntityName: "MetaLogEntry", into: context) as? MetaLogEntry else {
                        XCTFail()
                        return
                    }
                    logEntry.transactionID = "\(index)"
                    logEntry.sequenceNumber = Int32(index)
                    logEntry.previousSequenceNumber = Int32(index - 1)
                    logEntry.timestamp = Date().timeIntervalSinceNow
                    logEntry.type = MetaLogEntryType.insert
                }
                try context.save()
            }

            let log = try WriteAheadLog(coreDataStack: input)

            XCTAssertEqual(log.nextSequenceNumberBlock(1), expected)
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }

    func testNextSequenceNumberBlock() {

        let input = [5, 2, 10, 4, 22]
        let expected: [ClosedRange<Int>] = [1...5, 6...7, 8...17, 18...21, 22...43]

        do {
            let stack = CoreDataStackType(name: "MetaModel", managedObjectModel: MetaModel())
            let log = try WriteAheadLog(coreDataStack: stack)

            for index in 0..<input.count {
                let blockSize = input[index]
                XCTAssertEqual(log.nextSequenceNumberBlock(blockSize), expected[index])
            }

        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }

    func testTransactionLogEntryTypesForEntitySingleTypes() {

        let input = { () -> (entity: NSEntityDescription, entityUniqueID: String, logRecords: [MetaLogEntryType]) in

            let entity = NSEntityDescription()
            entity.name = "TestEntity"

            return (entity: entity, entityUniqueID: "10", logRecords: [MetaLogEntryType.insert, .insert])
        }()

        let expected: [String: Set<MetaLogEntryType>] = [input.entityUniqueID: [MetaLogEntryType.insert]]

        do {
            let stack = CoreDataStackType(name: "MetaModel", managedObjectModel: MetaModel())
            try stack.loadPersistentStores()

            let log = try WriteAheadLog(coreDataStack: stack)

            /// prime the database with mock records
            let context = stack.newBackgroundContext()

            try context.performAndWait {

                var index = 0

                ///
                /// Insert a record for each type
                ///
                for type in input.logRecords {
                    guard let logEntry = NSEntityDescription.insertNewObject(forEntityName: "MetaLogEntry", into: context) as? MetaLogEntry else {
                        XCTFail()
                        return
                    }
                    logEntry.transactionID = "\(index)"
                    logEntry.sequenceNumber = Int32(index)
                    logEntry.previousSequenceNumber = Int32(index - 1)
                    logEntry.timestamp = Date().timeIntervalSinceNow
                    logEntry.type = type
                    logEntry.updateEntityName = input.entity.name
                    logEntry.updateUniqueID   = input.entityUniqueID

                    index = index + 1
                }
                try context.save()
            }

            let entries = try log.transactionLogRecordTypesForEntity(input.entity)

            for (expectedKey, expectedTypes) in expected {

                guard let entryTypes = entries[expectedKey] else {
                    XCTFail()
                    return
                }

                for expectedType in expectedTypes {
                    XCTAssertTrue(entryTypes.contains(expectedType))
                }
            }
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }

    func testTransactionLogEntryTypesForEntityMultipleTypes() {

        let input = { () -> (entity: NSEntityDescription, entityUniqueID: String, logRecords: [MetaLogEntryType]) in 

            let entity = NSEntityDescription()
            entity.name = "TestEntity"

            return (entity: entity, entityUniqueID: "10", logRecords: [MetaLogEntryType.beginMarker, .endMarker, .insert, .update, .delete])
        }()

        let expected: [String: Set<MetaLogEntryType>] = [input.entityUniqueID: [MetaLogEntryType.beginMarker, .endMarker, .insert, .update, .delete]]

        do {
            let stack = CoreDataStackType(name: "MetaModel", managedObjectModel: MetaModel())
            try stack.loadPersistentStores()

            let log = try WriteAheadLog(coreDataStack: stack)

            /// prime the database with mock records
            let context = stack.newBackgroundContext()

            try context.performAndWait {

                var index = 0

                ///
                /// Insert a record for each type
                ///
                for type in input.logRecords {
                    guard let logEntry = NSEntityDescription.insertNewObject(forEntityName: "MetaLogEntry", into: context) as? MetaLogEntry else {
                        XCTFail()
                        return
                    }
                    logEntry.transactionID = "\(index)"
                    logEntry.sequenceNumber = Int32(index)
                    logEntry.previousSequenceNumber = Int32(index - 1)
                    logEntry.timestamp = Date().timeIntervalSinceNow
                    logEntry.type = type
                    logEntry.updateEntityName = input.entity.name
                    logEntry.updateUniqueID   = input.entityUniqueID

                    index = index + 1
                }
                try context.save()
            }

            let entries = try log.transactionLogRecordTypesForEntity(input.entity)

            for (expectedKey, expectedTypes) in expected {

                guard let entryTypes = entries[expectedKey] else {
                    XCTFail()
                    return
                }

                for expectedType in expectedTypes {
                    XCTAssertTrue(entryTypes.contains(expectedType))
                }
            }
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }

    func testFailedToObtainPermanentIDs() {

        do {
            let transactionStack = CoreDataStackType(name: "StackTestModel", managedObjectModel: ModelLoader.load(name: "StackTestModel1"))
            try transactionStack.loadPersistentStores()

            let metaStack = CoreDataStackType(name: "MetaModel", managedObjectModel: MetaModel())
            try metaStack.loadPersistentStores()

            let log = try WriteAheadLog(coreDataStack: metaStack)


            let input = try { () throws -> (entity: NSEntityDescription, count: Int) in

                guard let entity = NSEntityDescription.entity(forEntityName: "StackUser", in: transactionStack.viewContext) else {
                    throw NSError(domain: "Error", code: 1, userInfo: nil)
                }
                entity.managed = true
                entity.uniquenessAttributes = ["userName"]
                entity.logTransactions = true
                
                return (entity: entity, count: 5)
            }()
            let expected = "^Failed to obtain perminent id for transaction log record: *"


            /// prime the database with mock records
            let context = transactionStack.newBackgroundContext()

            context.performAndWait {

                ///
                /// Insert a record for each type
                ///
                for index in 0..<input.count {
                
                   let object = NSManagedObject(entity: input.entity, insertInto: context)
                    object.setValue("user\(index)", forKey: "userName")
                }
            }

            ///
            /// Remove the Persistent Stores to force an error when trying to obtainPerminentIDs.
            ///
            try metaStack.persistentStoreCoordinator.remove(metaStack.persistentStoreCoordinator.persistentStores[0])

            XCTAssertThrowsError(try log.logTransactionForContextChanges(context)) { (error) in

                if case WriteAheadLog.Errors.failedToObtainPermanentIDs(let message) = error {
                    XCTAssert(message.range(of: expected, options: .regularExpression) != nil)
                } else {
                    XCTFail("Wrong error thrown: \(error) is not equal to \(expected)")
                }
            }

        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }
}
