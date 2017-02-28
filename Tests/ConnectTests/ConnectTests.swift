///
///  ConnectTests.swift
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
///  Created by Tony Stone on 1/22/17.
///
import XCTest
import CoreData
@testable import Coherence

fileprivate let modelName = "ConnectTestModel"

class ConnectTests: XCTestCase {

    let testModel      = ModelLoader.load(name: modelName)
    let testEmptyModel = ModelLoader.load(name: modelName + "Empty")

    override func setUp() {
        super.setUp()

        do {
            try removePersistentStoreCache()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testConstructionWithModelName() {

        let input = self.testModel
        let expected = input

        XCTAssertEqual(Connect(name: modelName).managedObjectModel , expected)
    }

    func testConstructionWithModelNameAndModel() {

        let input = self.testModel
        let expected = input

        XCTAssertEqual(Connect(name: modelName, managedObjectModel: input).managedObjectModel , expected)
    }

    func testStart() throws {

        let input = (modelName: modelName, model: self.testModel)
        let expected = 1

        let expectation = self.expectation(description: "Completion block called")

        let connect = Connect(name: input.modelName, managedObjectModel: input.model)

        connect.start() { (error) in
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5) { (error) in

            if error == nil {
                XCTAssertEqual(connect.persistentStoreCoordinator.persistentStores.count, expected)
            }
        }
    }

    func testStartThrows() throws {

        let input = (modelName: modelName, model: self.testModel)
        let expected = 1

        let connect = Connect(name: input.modelName, managedObjectModel: input.model)
        try connect.start()

        XCTAssertEqual(connect.persistentStoreCoordinator.persistentStores.count, expected)
    }

    func testStart2xThrows() throws {

        let input = (modelName: modelName, model: self.testModel)
        let expected = 1

        let connect = Connect(name: input.modelName, managedObjectModel: input.model)
        try connect.start()
        try connect.start() /// Calling start a second time should be a no-op

        XCTAssertEqual(connect.persistentStoreCoordinator.persistentStores.count, expected)
    }

    func testStartWithIncompatibleStore() throws {

        let input = (modelName: modelName, model: self.testModel, emptyModel: self.testEmptyModel)

        /// Create the first instance of the persistent stores using the empty model
        do {
            try Connect(name: input.modelName, managedObjectModel: input.emptyModel).start()
        }

        /// Now create the second instance using the real model, it should throw an exception
        let connect = Connect(name: input.modelName, managedObjectModel: input.model)
        
        XCTAssertThrowsError(try connect.start())
    }

    func testConnectEntityMissingCanBeManaged() throws {

        let input = self.testModel.entitiesByName["ConnectEntity1"]
        let expected = true

        let connect = Connect(name: modelName, managedObjectModel: self.testModel)
        try connect.start()

        XCTAssertEqual(input?.managed, expected)
    }

    func testConnectMissingUniquenessAttributeEntityCannotBeManaged() throws {

        let input = self.testModel.entitiesByName["ConnectEntity4MissingUniquenessAttribute"]
        let expected = false

        let connect = Connect(name: modelName, managedObjectModel: self.testModel)
        try connect.start()

        XCTAssertEqual(input?.managed, expected)
    }

    func testPersistentStoreCoordinator() {

        do {
            let input = (id: Int64(1), string: "Test String 1")
            let expected = input

            let connect = Connect(name: modelName, managedObjectModel: self.testModel)

            try connect.start()

            ////
            /// Create a custom context which write directoy to the connect.persistentStoreCoordinator
            ///
            let editContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            editContext.persistentStoreCoordinator = connect.persistentStoreCoordinator

            ///
            /// View context to make sure we same threw the stack
            ///
            let viewContext = connect.viewContext

            var objectId: NSManagedObjectID? = nil

            try editContext.performAndWait {

                if let entity = NSEntityDescription.entity(forEntityName: "ConnectEntity1", in: editContext),
                    let object = NSEntityDescription.insertNewObject(forEntityName: "ConnectEntity1", into: editContext) as? ConnectEntity1 {

                    entity.logTransactions = true

                    object.id              = input.id
                    object.stringAttribute = input.string


                    try editContext.save()

                    objectId = object.objectID
                }
            }

            var savedObject: NSManagedObject? = nil

            try viewContext.performAndWait {
                if let objectId = objectId {
                    savedObject = try viewContext.existingObject(with: objectId)
                }
            }

            XCTAssertNotNil(savedObject)
            
            if let savedObject = savedObject as? ConnectEntity1 {
                
                XCTAssertEqual(savedObject.id,              expected.id)
                XCTAssertEqual(savedObject.stringAttribute, expected.string)
                
            } else {
                XCTFail()
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testCRUDCreateAndRead () throws {

        let input = (id: Int64(1), string: "Test String 1")
        let expected = input

        let connect = Connect(name: modelName, managedObjectModel: self.testModel)

        try connect.start()

        let editContext = connect.newBackgroundContext()
        let mainContext = connect.viewContext

        var objectId: NSManagedObjectID? = nil

        editContext.performAndWait {

            if let entity = NSEntityDescription.entity(forEntityName: "ConnectEntity1", in: editContext),
                let object = NSEntityDescription.insertNewObject(forEntityName: "ConnectEntity1", into:editContext) as? ConnectEntity1 {

                entity.logTransactions = true

                object.id              = input.id
                object.stringAttribute = input.string

                do {
                    try editContext.save()
                } catch {
                    XCTFail()
                }
                objectId = object.objectID
            }
        }

        var savedObject: NSManagedObject? = nil

        mainContext.performAndWait {
            if let objectId = objectId {
                do {
                    savedObject = try mainContext.existingObject(with: objectId)
                } catch {
                    XCTFail("\(error)")
                }
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

    func testCRUDUpdate () throws {

        let input = (insert: (id: Int64(1), string: "Test String 1"),
                     update: (id: Int64(1), string: "Test String 2"))
        let expected = input.update

        let connect = Connect(name: modelName, managedObjectModel: self.testModel)

        try connect.start()

        let editContext = connect.newBackgroundContext()
        let mainContext = connect.viewContext

        var objectId: NSManagedObjectID? = nil

        editContext.performAndWait {

            if let entity = NSEntityDescription.entity(forEntityName: "ConnectEntity1", in: editContext),
                let object = NSEntityDescription.insertNewObject(forEntityName: "ConnectEntity1", into:editContext) as? ConnectEntity1 {

                entity.logTransactions = true

                object.id              = input.insert.id
                object.stringAttribute = input.insert.string

                do {
                    try editContext.save()
                } catch {
                    XCTFail()
                }

                object.id              = input.update.id
                object.stringAttribute = input.update.string

                do {
                    try editContext.save()
                } catch {
                    XCTFail()
                }

                objectId = object.objectID
            }
        }

        var savedObject: NSManagedObject? = nil

        mainContext.performAndWait {
            if let objectId = objectId {
                do {
                    savedObject = try mainContext.existingObject(with: objectId)
                } catch {
                    XCTFail("\(error)")
                }
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

    func testCRUDDelete () throws {

        let input = (id: Int64(1), string: "Test String 1")

        let connect = Connect(name: modelName, managedObjectModel: self.testModel)

        try connect.start()

        let editContext = connect.newBackgroundContext()
        let mainContext = connect.viewContext

        editContext.performAndWait {

            if let entity = NSEntityDescription.entity(forEntityName: "ConnectEntity1", in: editContext),
                let object = NSEntityDescription.insertNewObject(forEntityName: "ConnectEntity1", into:editContext) as? ConnectEntity1 {

                entity.logTransactions = true

                object.id              = input.id
                object.stringAttribute = input.string

                do {
                    try editContext.save()
                } catch {
                    XCTFail()
                }

                editContext.delete(object)
                
                do {
                    try editContext.save()
                } catch {
                    XCTFail()
                }
            }
        }

        mainContext.performAndWait {
            let fetchRequest: NSFetchRequest<ConnectEntity1> = ConnectEntity1.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", input.id)

            do {
                let result = try mainContext.count(for: fetchRequest)

                XCTAssertEqual(result, 0)
            } catch {
                XCTFail()
            }
        }
    }

    func testExecuteGenericAction()  {

        let input = MockGenericAction()
        let expected = (state: ActionState.finished, completionStatus: ActionCompletionStatus.successful)

        do {
            let connect = Connect(name: modelName, managedObjectModel: self.testModel)

            try connect.start()

            let expecation = self.expectation(description: "GenericAction Completion Block Gets Called")

            let proxy = try connect.execute(input) { _ in
                expecation.fulfill()
            }

            self.waitForExpectations(timeout: 5) { error in
                if let error = error {
                    XCTFail("waitForExpectationsWithTimeout errored: \(error)")
                } else {

                    XCTAssertEqual(proxy.state,            expected.state)
                    XCTAssertEqual(proxy.completionStatus, expected.completionStatus)
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testExecuteEntityAction() {
    
        let input: [ConnectEntity1] = []
        let expected = (state: ActionState.finished, completionStatus: ActionCompletionStatus.successful)

        do {
            let connect = Connect(name: modelName, managedObjectModel: self.testModel)

            try connect.start()

            let expecation = self.expectation(description: "EntityAction Completion Block Gets Called")

            let proxy = try connect.execute(MockListAction(testValues: input)) { _ in
                expecation.fulfill()
            }

            self.waitForExpectations(timeout: 5) { error in
                if let error = error {
                    XCTFail("waitForExpectationsWithTimeout errored: \(error)")
                } else {

                    XCTAssertEqual(proxy.state,            expected.state)
                    XCTAssertEqual(proxy.completionStatus, expected.completionStatus)
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testExecuteEntityActionUnmanagedEntity() {
    
        let input = MockListActionUnmanaged()
        let expected = "Entity 'ConnectEntity3Unmanaged' not managed by Coherence.Connect"

        do {
            let connect = Connect(name: modelName, managedObjectModel: self.testModel)

            try connect.start()

            XCTAssertThrowsError( try connect.execute(input) ) { (error) in

                if case Connect.Errors.unmanagedEntity(let message) = error {
                    XCTAssertEqual(message, expected)
                } else {
                    XCTFail("Wrong error thrown: \(error) is not equal to \(expected)")
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }
}
