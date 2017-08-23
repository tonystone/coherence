///
///  ActionContext+MergeTests.swift
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
///  Created by Tony Stone on 2/8/17.
///
import XCTest
import CoreData
@testable import Coherence

fileprivate let modelName = "ConnectTestModel"

class ActionContextMergeTests: XCTestCase {

    override func setUp() {
        super.setUp()

        do {
            try TestPersistentStoreManager.removePersistentStoreCache()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testMergeUnmanagedObject() throws {

        let connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
        try connect.start()

        let actionContext = connect.newActionContext()

        let input = try ConnectEntity3Unmanaged.newTestObjects(for: actionContext, count: 10)
        let expected = "Entity 'ConnectEntity3Unmanaged' not managed, cannot merge objects."
        
        ///
        /// Execute the merge which should ignore all items
        ///
        try actionContext.performAndWait {
            XCTAssertThrowsError(try actionContext.merge(objects: input.objects, for: input.entity)) { (error) in

                if case Coherence.Errors.unmanagedEntity(let message) = error {
                    XCTAssertEqual(message, expected)
                } else {
                    XCTFail("Wrong error thrown: \(error) is not equal to \(expected)")
                }
            }
        }
    }

    func testMergeUnmanagedObjectUnnamedEntity() throws {

        let connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
        try connect.start()

        let actionContext = connect.newActionContext()

        let input = { () -> (objects: [ConnectEntity3Unmanaged], entity: NSEntityDescription) in
            let entity = NSEntityDescription()
            entity.managed = true

            return ([], entity)
        }()
        let expected = "Entity does not have a name, cannot merge objects."

        ///
        /// Execute the merge which should ignore all items
        ///
        try actionContext.performAndWait {
            XCTAssertThrowsError(try actionContext.merge(objects: input.objects, for: input.entity)) { (error) in

                if case Coherence.Errors.missingEntityName(let message) = error {
                    XCTAssertEqual(message, expected)
                } else {
                    XCTFail("Wrong error thrown: \(error) is not equal to \(expected)")
                }
            }
        }
    }

    func testMergeInsert() {

        do {
            let connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
            try connect.start()

            let actionContext = connect.newActionContext()
            let viewContext   = connect.viewContext

            let input    = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))
            let expected = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))

            ///
            /// Execute the merge to test the insert capabilities
            ///
            try actionContext.performAndWait {
                try actionContext.merge(objects: input.objects, for: input.entity)
            }

            viewContext.performAndWait {
                do {

                    for expectedObject in expected.objects {

                        let fetch = { () -> NSFetchRequest<ConnectEntity1> in

                            let fetch = NSFetchRequest<ConnectEntity1>()
                            fetch.entity = expected.entity
                            fetch.predicate = NSPredicate(format: "id == %ld", expectedObject.id)

                            return fetch
                        }()

                        let results = try viewContext.fetch(fetch)
                        
                        guard let resultObject = results.last else {
                            XCTFail()
                            return
                        }
                        XCTAssertEqual(resultObject.id,                 expectedObject.id)
                        XCTAssertEqual(resultObject.boolAttribute,      expectedObject.boolAttribute)
                        XCTAssertEqual(resultObject.stringAttribute,    expectedObject.stringAttribute)
                        XCTAssertEqual(resultObject.binaryAttribute,    expectedObject.binaryAttribute)
                    }
                } catch {
                    XCTFail()
                }
            }

        } catch {
            XCTFail("\(error)")
        }
    }

    func testMergeInsertReversedOrderInput() {

        do {
            let connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
            try connect.start()

            let actionContext = connect.newActionContext()
            let viewContext   = connect.viewContext

            let input    = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))
            let expected = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))

            ///
            /// Execute the merge to test the insert capabilities
            ///
            try actionContext.performAndWait {
                /// Reverse the order beforing inserting to make sure a reverse sort of the DB works.
                try actionContext.merge(objects: input.objects.reversed(), for: input.entity)
            }

            viewContext.performAndWait {
                do {

                    for expectedObject in expected.objects {

                        let fetch = { () -> NSFetchRequest<ConnectEntity1> in

                            let fetch = NSFetchRequest<ConnectEntity1>()
                            fetch.entity = expected.entity
                            fetch.predicate = NSPredicate(format: "id == %ld", expectedObject.id)

                            return fetch
                        }()

                        let results = try viewContext.fetch(fetch)

                        guard let resultObject = results.last else {
                            XCTFail()
                            return
                        }
                        XCTAssertEqual(resultObject.id,                 expectedObject.id)
                        XCTAssertEqual(resultObject.boolAttribute,      expectedObject.boolAttribute)
                        XCTAssertEqual(resultObject.stringAttribute,    expectedObject.stringAttribute)
                        XCTAssertEqual(resultObject.binaryAttribute,    expectedObject.binaryAttribute)
                    }
                } catch {
                    XCTFail()
                }
            }
            
        } catch {
            XCTFail("\(error)")
        }
    }

    func testMergeUpdate() {

        do {
            let connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
            try connect.start()

            let actionContext = connect.newActionContext()
            let viewContext   = connect.viewContext

            let input    = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Update", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))
            let expected = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Update", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))

            ///
            /// Prime the database with objects
            ///
            try actionContext.performAndWait {
                let (_, objects) = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))
                for object in  objects {
                    actionContext.insert(object)
                }
                try actionContext.save()
            }

            ///
            /// Now execute the merge with updated objects
            ///
            try actionContext.performAndWait {
                try actionContext.merge(objects: input.objects, for: input.entity)
            }

            ///
            /// Now test that the view contains the updated objects.
            ///
            viewContext.performAndWait {
                do {

                    for expectedObject in expected.objects {

                        let fetch = { () -> NSFetchRequest<ConnectEntity1> in

                            let fetch = NSFetchRequest<ConnectEntity1>()
                            fetch.entity = expected.entity
                            fetch.predicate = NSPredicate(format: "id == %ld", expectedObject.id)

                            return fetch
                        }()

                        let results = try viewContext.fetch(fetch)

                        guard let resultObject = results.last else {
                            XCTFail()
                            return
                        }

                        XCTAssertEqual(resultObject.id,                 expectedObject.id)
                        XCTAssertEqual(resultObject.boolAttribute,      expectedObject.boolAttribute)
                        XCTAssertEqual(resultObject.stringAttribute,    expectedObject.stringAttribute)
                        XCTAssertEqual(resultObject.binaryAttribute,    expectedObject.binaryAttribute)
                    }
                } catch {
                    XCTFail()
                }
            }
            
        } catch {
            XCTFail("\(error)")
        }
    }

    func testMergeDelete() {

        do {
            let connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
            try connect.start()

            let actionContext = connect.newActionContext()
            let viewContext   = connect.viewContext

            let input    = try ConnectEntity1.newTestObjects(for: actionContext, count: 0, boolValue: true, stringValue: "Delete", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))
            let expected = try ConnectEntity1.newTestObjects(for: actionContext, count: 0, boolValue: true, stringValue: "Delete", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))

            ///
            /// Prime the database with objects
            ///
            try actionContext.performAndWait {
                let (_, objects) = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))

                for object in  objects {
                    actionContext.insert(object)
                }
                try actionContext.save()
            }

            ///
            /// Now execute the merge to delete the objects
            ///
            try actionContext.performAndWait {
                try actionContext.merge(objects: input.objects, for: input.entity)
            }

            ///
            /// Now test that the view does NOT contains the deleted objects.
            ///
            viewContext.performAndWait {
                do {
                
                    let fetch = { () -> NSFetchRequest<ConnectEntity1> in

                        let fetch = NSFetchRequest<ConnectEntity1>()
                        fetch.entity = expected.entity

                        return fetch
                    }()

                    let results = try viewContext.fetch(fetch)

                    XCTAssertEqual(results.count, expected.objects.count)
                } catch {
                    XCTFail()
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testMergeUpdateIgnoreLocalUpdatedItems() throws {

        let connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
        try connect.start()

        let editContext = connect.newBackgroundContext()
        let actionContext = connect.newActionContext()
        let viewContext   = connect.viewContext

        let input    = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert",    dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))
        let expected = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "New value", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))

        try editContext.performAndWait {

            /// Turn off logging for the insert
            input.entity.logTransactions = false

            ///
            /// Insert the items first
            ///
            /// Note: these should not be logged as inserted
            ///
            for object in input.objects {
                editContext.insert(object)
            }
            try editContext.save()

            /// Turn on logging for the updates
            input.entity.logTransactions = true

            ///
            /// Now update them
            ///
            /// Note: these should be logged
            ///
            for object in input.objects {
                object.stringAttribute = "New value"
            }
            try editContext.save()
        }

        ///
        /// Execute the merge which should ignore all items
        ///
        try actionContext.performAndWait {
            try actionContext.merge(objects: input.objects, for: input.entity)
        }

        /// All Values should remain with the updated values
        try viewContext.performAndWait {
            for expectedObject in expected.objects {

                let fetch = { () -> NSFetchRequest<ConnectEntity1> in

                    let fetch = NSFetchRequest<ConnectEntity1>()
                    fetch.entity = expected.entity
                    fetch.predicate = NSPredicate(format: "id == %ld", expectedObject.id)

                    return fetch
                }()

                let results = try viewContext.fetch(fetch)

                guard let resultObject = results.last else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(resultObject.id,                 expectedObject.id)
                XCTAssertEqual(resultObject.boolAttribute,      expectedObject.boolAttribute)
                XCTAssertEqual(resultObject.stringAttribute,    expectedObject.stringAttribute)
                XCTAssertEqual(resultObject.binaryAttribute,    expectedObject.binaryAttribute)
            }
        }
    }

    func testMergeInsertIgnoreLocalDeletedItems() throws {

        let connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
        try connect.start()

        let editContext = connect.newBackgroundContext()
        let actionContext = connect.newActionContext()
        let viewContext   = connect.viewContext

        let input    = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert",    dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))
        let expected = 0

        try editContext.performAndWait {

            let primerObjects = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert",    dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))

            /// Turn off logging for the insert
            primerObjects.entity.logTransactions = false

            ///
            /// Insert the items first
            ///
            /// Note: these should not be logged as inserted
            ///
            for object in primerObjects.objects {
                editContext.insert(object)
            }
            try editContext.save()

            /// Turn on logging for the updates
            primerObjects.entity.logTransactions = true

            ///
            /// Now delete them
            ///
            /// Note: these should be logged
            ///
            for object in primerObjects.objects {
                editContext.delete(object)
            }
            try editContext.save()
        }

        ///
        /// Execute the merge which should ignore all items
        ///
        try actionContext.performAndWait {
            try actionContext.merge(objects: input.objects, for: input.entity)
        }

        /// All Values should remain with the updated values
        try viewContext.performAndWait {

            let fetch = { () -> NSFetchRequest<ConnectEntity1> in

                let fetch = NSFetchRequest<ConnectEntity1>()
                fetch.entity = input.entity

                return fetch
            }()

            let results = try viewContext.fetch(fetch)

            ///
            /// Should be zero (0) records
            ///
            XCTAssertEqual(results.count, expected)
        }
    }

    func testMergeDeleteIgnoreLocalUpdatedItems() throws {

        let connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
        try connect.start()

        let editContext = connect.newBackgroundContext()
        let actionContext = connect.newActionContext()
        let viewContext   = connect.viewContext

        let input    = try ConnectEntity1.newTestObjects(for: actionContext, count: 0, boolValue: true, stringValue: "Insert",    dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))
        let expected = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "New value", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))

        try editContext.performAndWait {

            let primerObjects = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))

            /// Turn off logging for the insert
            primerObjects.entity.logTransactions = false

            ///
            /// Insert the items first
            ///
            /// Note: these should not be logged as inserted
            ///
            for object in primerObjects.objects {
                editContext.insert(object)
            }
            try editContext.save()

            /// Turn on logging for the updates
            primerObjects.entity.logTransactions = true

            ///
            /// Now update them
            ///
            /// Note: these should be logged
            ///
            for object in primerObjects.objects {
                object.stringAttribute = "New value"
            }
            try editContext.save()
        }

        ///
        /// Execute the merge which should ignore all items
        ///
        try actionContext.performAndWait {
            try actionContext.merge(objects: input.objects, for: input.entity)
        }

        /// All Values should remain with the updated values
        try viewContext.performAndWait {
            for expectedObject in expected.objects {

                let fetch = { () -> NSFetchRequest<ConnectEntity1> in

                    let fetch = NSFetchRequest<ConnectEntity1>()
                    fetch.entity = expected.entity
                    fetch.predicate = NSPredicate(format: "id == %ld", expectedObject.id)

                    return fetch
                }()

                let results = try viewContext.fetch(fetch)

                guard let resultObject = results.last else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(resultObject.id,                 expectedObject.id)
                XCTAssertEqual(resultObject.boolAttribute,      expectedObject.boolAttribute)
                XCTAssertEqual(resultObject.stringAttribute,    expectedObject.stringAttribute)
                XCTAssertEqual(resultObject.binaryAttribute,    expectedObject.binaryAttribute)
            }
        }
    }

    func testMergeUpdateWithoutWriteAheadLog() throws {

        let connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
        try connect.start()

        let editContext = connect.newBackgroundContext()
        let actionContext = connect.newActionContext()
        let viewContext   = connect.viewContext

        let input    = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))
        let expected = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))

        try editContext.performAndWait {

            let primerObjects = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))

            /// Turn off logging for the insert
            primerObjects.entity.logTransactions = false

            ///
            /// Insert the items first
            ///
            /// Note: these should not be logged as inserted
            ///
            for object in primerObjects.objects {
                editContext.insert(object)
            }
            try editContext.save()

            /// Turn on logging for the updates
            primerObjects.entity.logTransactions = true

            ///
            /// Now update them
            ///
            /// Note: these should be logged
            ///
            for object in primerObjects.objects {
                object.stringAttribute = "New value"
            }
            try editContext.save()
        }

        ///
        /// Remove the Logger before executing the merge
        /// this will ignore the transactions in the log 
        /// and update the values back to their previous 
        /// vaues.
        actionContext.logger = nil

        try actionContext.performAndWait {
            try actionContext.merge(objects: input.objects, for: input.entity)
        }

        /// All Values should remain with the updated values
        try viewContext.performAndWait {
            for expectedObject in expected.objects {

                let fetch = { () -> NSFetchRequest<ConnectEntity1> in

                    let fetch = NSFetchRequest<ConnectEntity1>()
                    fetch.entity = expected.entity
                    fetch.predicate = NSPredicate(format: "id == %ld", expectedObject.id)

                    return fetch
                }()

                let results = try viewContext.fetch(fetch)

                guard let resultObject = results.last else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(resultObject.id,                 expectedObject.id)
                XCTAssertEqual(resultObject.boolAttribute,      expectedObject.boolAttribute)
                XCTAssertEqual(resultObject.stringAttribute,    expectedObject.stringAttribute)
                XCTAssertEqual(resultObject.binaryAttribute,    expectedObject.binaryAttribute)
            }
        }
    }
}
