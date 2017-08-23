///
///  LoggingContextTests.swift
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
///  Created by Tony Stone on 2/26/17.
///
import XCTest
import Foundation
import CoreData

@testable import Coherence

class LoggingContextTests: XCTestCase {

    override func setUp() {
        super.setUp()

        do {
            try TestPersistentStoreManager.removePersistentStoreCache()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testSave() throws {

        let input = (id: Int64(1), string: "Test String 1")
        let expected = input

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: "ConnectTestModel")
        try connect.start()

        let editContext = connect.newBackgroundContext()
        let mainContext = connect.viewContext

        var objectId: NSManagedObjectID? = nil

        try editContext.performAndWait {

            if let entity = NSEntityDescription.entity(forEntityName: "ConnectEntity1", in: editContext),
                let object = NSEntityDescription.insertNewObject(forEntityName: "ConnectEntity1", into:editContext) as? ConnectEntity1 {

                entity.logTransactions = true

                object.id              = input.id
                object.stringAttribute = input.string

                try editContext.save()

                objectId = object.objectID
            }
        }

        var savedObject: NSManagedObject? = nil

        try mainContext.performAndWait {
            if let objectId = objectId {
                savedObject = try mainContext.existingObject(with: objectId)
            }
        }

        XCTAssertNotNil(savedObject)

        if let savedObject = savedObject as? ConnectEntity1 {

            XCTAssertEqual(savedObject.id,              expected.id)
            XCTAssertEqual(savedObject.stringAttribute, expected.string)
            
        } else {
            XCTFail()
        }
    }

    func testSaveNoWriteAheadLog() throws {
    
        let input = (id: Int64(1), string: "Test String 1")
        let expected = input

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: "ConnectTestModel")
        try connect.start()

        /// Create a logging context without the write ahead logger
        let editContext = LoggingContext(concurrencyType: .privateQueueConcurrencyType)
        editContext.persistentStoreCoordinator = connect.persistentStoreCoordinator

        let mainContext = connect.viewContext

        var objectId: NSManagedObjectID? = nil

        try editContext.performAndWait {

            if let entity = NSEntityDescription.entity(forEntityName: "ConnectEntity1", in: editContext),
                let object = NSEntityDescription.insertNewObject(forEntityName: "ConnectEntity1", into:editContext) as? ConnectEntity1 {

                entity.logTransactions = true

                object.id              = input.id
                object.stringAttribute = input.string

                try editContext.save()

                objectId = object.objectID
            }
        }

        var savedObject: NSManagedObject? = nil

        try mainContext.performAndWait {
            if let objectId = objectId {
                savedObject = try mainContext.existingObject(with: objectId)
            }
        }

        XCTAssertNotNil(savedObject)

        if let savedObject = savedObject as? ConnectEntity1 {

            XCTAssertEqual(savedObject.id,              expected.id)
            XCTAssertEqual(savedObject.stringAttribute, expected.string)
            
        } else {
            XCTFail()
        }
    }

    func testSaveWithRollback() throws {

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: "ConnectTestModel")
        try connect.start()

        let editContext = connect.newBackgroundContext()

        try editContext.performAndWait {

            if let entity = NSEntityDescription.entity(forEntityName: "ConnectEntity1", in: editContext) {
                entity.logTransactions = true

                let _ = NSEntityDescription.insertNewObject(forEntityName: "ConnectEntity1", into:editContext)

                XCTAssertThrowsError(try editContext.save())
            }
        }
    }
}


