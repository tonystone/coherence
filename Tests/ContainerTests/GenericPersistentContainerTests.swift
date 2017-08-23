///
///  GenericCoreDataStackTests.swift
///
///  Copyright 2016 The Climate Corporation
///  Copyright 2016 Tony Stone
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
///  Created by Tony Stone on 10/31/16.
///
import XCTest
import CoreData

@testable import Coherence

fileprivate let firstName = "First"
fileprivate let lastName  = "Last"
fileprivate let userName  = "First Last"

class GenericPersistentContainerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        do {
            try TestPersistentStoreManager.removePersistentStoreCache()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    override func tearDown() {
        do {
            try TestPersistentStoreManager.removePersistentStoreCache()
        } catch {
            XCTFail(error.localizedDescription)
        }
        super.tearDown()
    }

    func testDefaultStoreLocation() {

        let input = GenericPersistentContainer<ContextStrategy.Mixed>.defaultStoreLocation()
        let expected = { () -> URL in

            let possibleURLs = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)

            return possibleURLs[0]
        }()

        XCTAssertEqual(input, expected)
    }

    func testInitWithName() {

        let input  = "ContainerTestModel4"
        let expected = (name: input, model: TestModelLoader.load(name: input))

        let container = GenericPersistentContainer<ContextStrategy.Mixed>(name: input)

        XCTAssertEqual(container.name,               expected.name)
        XCTAssertEqual(container.managedObjectModel, expected.model)
    }

    func testInitWithNameAndModel() {

        let input  = (name: "ContainerTestModel", model: TestModelLoader.load(name: "ContainerTestModel4"))
        let expected = input

        let container = GenericPersistentContainer<ContextStrategy.Mixed>(name: input.name, managedObjectModel: input.model)

        XCTAssertEqual(container.name,               expected.name)
        XCTAssertEqual(container.managedObjectModel, expected.model)
    }

    func testInitWithAsyncErrorHandler() {

        let model     = TestModelLoader.load(name: "ContainerTestModel1")
        let name      = "ContainerTestModel1"

        let container = GenericPersistentContainer<ContextStrategy.Mixed>(name: name, managedObjectModel: model, asyncErrorBlock: { (error) -> Void in
            // Async Error block
            print(error.localizedDescription)
        })

        do {
            let _ = try container.attachPersistentStores()

            XCTAssertTrue(TestPersistentStoreManager.persistentStoreExists(storePrefix: name, storeType: NSSQLiteStoreType))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testDefaultErrorHandlingBlock() {

        enum TestErrors: Error {
            case testError
        }

        let input = TestErrors.testError

        ///
        /// Note: there is really no way at the moment to validate the output of the default handler so this is just to exercise it for test coverage completion.
        ///
        Coherence.defaultAsyncErrorHandlingBlock(tag: "Testing")(input)
    }

    func testAttachPersistentStoresWithConfigurations() throws {
        
        let input = (modelName: "ContainerTestModel1", model: TestModelLoader.load(name: "ContainerTestModel1"), configuration: StoreConfiguration(fileName: "ContainerTestModel1.\(NSSQLiteStoreType.lowercased())"))
        let expected = TestPersistentStoreManager.defaultPersistentStoreDirectory().appendingPathComponent("ContainerTestModel1.\(NSSQLiteStoreType.lowercased())")

        let container = GenericPersistentContainer<ContextStrategy.Mixed>(name: input.modelName, managedObjectModel: input.model)

        do {
            let _ = try container.attachPersistentStores(for: [input.configuration])
            
            XCTAssertTrue(TestPersistentStoreManager.persistentStoreExists(url: expected))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testAttachPersistentStoresWithEmptyDescriptions() throws {

        let input = (modelName: "ContainerTestModel1",
                     model: TestModelLoader.load(name: "ContainerTestModel1"),
                     configurations: [] as [StoreConfiguration])
        let expected = TestPersistentStoreManager.defaultPersistentStoreDirectory().appendingPathComponent("ContainerTestModel1.sqlite")

        let container = GenericPersistentContainer<ContextStrategy.IndirectNested>(name: input.modelName, managedObjectModel: input.model)

        do {
            let _ = try container.attachPersistentStores(for: input.configurations)

            let exists = TestPersistentStoreManager.persistentStoreExists(url: expected)
            XCTAssertTrue(exists)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testAttachPersistentStoresWithMultiConfigurationAndSQLiteStoreType() throws {

        let input = (modelName: "ContainerTestModel3",
                     model: TestModelLoader.load(name: "ContainerTestModel3"),
                     transientConfiguration:  StoreConfiguration(fileName: "ContainerTestModel3-transient.sqlite",  name: "TransientEntities",  type: NSSQLiteStoreType),
                     persistentConfiguration: StoreConfiguration(fileName: "ContainerTestModel3-persistent.sqlite", name: "PersistentEntities", type: NSSQLiteStoreType))

        let expected = (transientUrl: TestPersistentStoreManager.defaultPersistentStoreDirectory().appendingPathComponent("ContainerTestModel3-transient.sqlite"), persistentUrl: TestPersistentStoreManager.defaultPersistentStoreDirectory().appendingPathComponent("ContainerTestModel3-persistent.sqlite"))

        let container = GenericPersistentContainer<ContextStrategy.IndirectNested>(name: input.modelName, managedObjectModel: input.model)

        do {
            let _ = try container.attachPersistentStores(for: [input.transientConfiguration, input.persistentConfiguration])

            XCTAssertTrue(TestPersistentStoreManager.persistentStoreExists(url: expected.transientUrl), "Persistent store does not exist on disk.")
            XCTAssertTrue(TestPersistentStoreManager.persistentStoreExists(url: expected.persistentUrl), "Persistent store does not exist on disk.")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testAttachPersistentStoresWithMultiConfigurationAndInMemoryType() throws {
        
        let input = (modelName: "ContainerTestModel3",
                     model: TestModelLoader.load(name: "ContainerTestModel3"),
                     transientConfiguration:  StoreConfiguration(fileName: "ContainerTestModel3-transient.sqlite",  name: "TransientEntities",  type: NSInMemoryStoreType),
                     persistentConfiguration: StoreConfiguration(fileName: "ContainerTestModel3-persistent.sqlite", name: "PersistentEntities", type: NSInMemoryStoreType))

        let expected = (transientUrl: TestPersistentStoreManager.defaultPersistentStoreDirectory().appendingPathComponent("ContainerTestModel3-transient.sqlite"), persistentUrl: TestPersistentStoreManager.defaultPersistentStoreDirectory().appendingPathComponent("ContainerTestModel3-persistent.sqlite"))

        let container = GenericPersistentContainer<ContextStrategy.IndirectNested>(name: input.modelName, managedObjectModel: input.model)

        do {
            let _ = try container.attachPersistentStores(for: [input.transientConfiguration, input.persistentConfiguration])

            XCTAssertFalse(TestPersistentStoreManager.persistentStoreExists(url: expected.transientUrl), "Persistent store exist on disk but should not.")
            XCTAssertFalse(TestPersistentStoreManager.persistentStoreExists(url: expected.persistentUrl), "Persistent store exist on disk but should not.")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testAttachPersistentStoresWithMultiConfigurationAndMixedType() throws {
        
        let input = (modelName: "ContainerTestModel3",
                     model: TestModelLoader.load(name: "ContainerTestModel3"),
                     transientConfiguration:  StoreConfiguration(fileName: "ContainerTestModel3-transient.sqlite",  name: "TransientEntities",  type: NSInMemoryStoreType),
                     persistentConfiguration: StoreConfiguration(fileName: "ContainerTestModel3-persistent.sqlite", name: "PersistentEntities", type: NSSQLiteStoreType))

        let expected = (transientUrl: TestPersistentStoreManager.defaultPersistentStoreDirectory().appendingPathComponent("ContainerTestModel3-transient.sqlite"), persistentUrl: TestPersistentStoreManager.defaultPersistentStoreDirectory().appendingPathComponent("ContainerTestModel3-persistent.sqlite"))

        let container = GenericPersistentContainer<ContextStrategy.DirectIndependent>(name: input.modelName, managedObjectModel: input.model)

        do {
            let _ = try container.attachPersistentStores(for: [input.transientConfiguration, input.persistentConfiguration])

            XCTAssertFalse(TestPersistentStoreManager.persistentStoreExists(url: expected.transientUrl), "Persistent store exist on disk but should not.")
            XCTAssertTrue(TestPersistentStoreManager.persistentStoreExists(url: expected.persistentUrl), "Persistent store does not exist on disk.")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testAttachPersistentStoresWithMultiConfigurationAndDefaultStoreType() throws {
        
        let model = TestModelLoader.load(name: "ContainerTestModel3")
        let name  = "ContainerTestModel3"

        let container = GenericPersistentContainer<ContextStrategy.DirectIndependent>(name: name, managedObjectModel: model)

        do {
            let _ = try container.attachPersistentStores()

            XCTAssertTrue(TestPersistentStoreManager.persistentStoreExists(storePrefix: name, storeType: NSSQLiteStoreType))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testAttachPersistentStoresWithOverwriteIncompatibleStore() throws {

        let input = (modelName: "ContainerTestModel1",
                     model1: TestModelLoader.load(name: "ContainerTestModel1"),
                     model2: TestModelLoader.load(name: "ContainerTestModel2"),
                     configuration: StoreConfiguration(fileName: "ContainerTestModel1.sqlite", overwriteIncompatibleStore: true))
        let expected = TestPersistentStoreManager.defaultPersistentStoreDirectory().appendingPathComponent("ContainerTestModel1.sqlite")

        do {
            let container = GenericPersistentContainer<ContextStrategy.DirectIndependent>(name: input.modelName, managedObjectModel: input.model1)

            try container.attachPersistentStores(for: [input.configuration])
        }
        let storeDate = try TestPersistentStoreManager.persistentStoreDate(url: expected)

        /// Sleep so we have a significant change in date of the store file.
        sleep(1)

        let container = GenericPersistentContainer<ContextStrategy.DirectIndependent>(name: input.modelName, managedObjectModel: input.model2)

        try container.attachPersistentStores(for: [input.configuration])

        XCTAssertTrue(try TestPersistentStoreManager.persistentStoreDate(url: expected) > storeDate)
    }

    func testDetachPersistentStore() throws {

        let input = (modelName: "ContainerTestModel1", model: TestModelLoader.load(name: "ContainerTestModel1"), configuration: StoreConfiguration())

        let container = GenericPersistentContainer<ContextStrategy.Mixed>(name: input.modelName, managedObjectModel: input.model)

        do {
            let testStore = try container.attachPersistentStore(for: input.configuration)

            XCTAssertTrue(container.persistentStoreCoordinator.persistentStores.contains(testStore))

            try container.detach(persistentStore: testStore)

            XCTAssertFalse(container.persistentStoreCoordinator.persistentStores.contains(testStore))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testDetachPersistentStores() throws {

        let input = (modelName: "ContainerTestModel1", model: TestModelLoader.load(name: "ContainerTestModel1"), configuration: StoreConfiguration())

        let container = GenericPersistentContainer<ContextStrategy.Mixed>(name: input.modelName, managedObjectModel: input.model)

        do {
            let testStore = try container.attachPersistentStore(for: input.configuration)

            XCTAssertTrue(container.persistentStoreCoordinator.persistentStores.contains(testStore))

            try container.detach(persistentStores: [testStore])

            XCTAssertFalse(container.persistentStoreCoordinator.persistentStores.contains(testStore))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testCRUD () throws {

        let input = (firstName: "firstName", lastName: "lastName", userName: "userName")

        let container = GenericPersistentContainer<ContextStrategy.Mixed>(name: "ContainerTestModel1", managedObjectModel:  TestModelLoader.load(name: "ContainerTestModel1"))
        try container.attachPersistentStores()

        let editContext = container.newBackgroundContext()
        let viewContext = container.viewContext

        var userId: NSManagedObjectID = NSManagedObjectID()

        ///
        /// Insert the object into the editContext and get it's permanent ObjectID.
        ///
        try editContext.performAndWait {

            if let insertedUser = NSEntityDescription.insertNewObject(forEntityName: "ContainerUser", into:editContext) as? ContainerUser {

                insertedUser.firstName = input.firstName
                insertedUser.lastName  = input.lastName
                insertedUser.userName  = input.userName

                try editContext.obtainPermanentIDs(for: [insertedUser])

                userId = insertedUser.objectID
            }
        }

        ///
        /// Wait for the viewContext NSManagedObjectContextObjectsDidChange notification and validate that this object was inserted into the viewContext.
        ///
        /// Note: this will happen when the edit context is saved
        ///
        self.expectation(forNotification: NSNotification.Name.NSManagedObjectContextObjectsDidChange.rawValue, object: viewContext) { notification -> Bool in

            if let inserted = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {

                let objectIds = inserted.map { $0.objectID }

                return objectIds.contains(userId)
            }
            return false
        }

        ///
        /// Now save the edit context to trigger the updates on the viewContext.
        ///
        try editContext.performAndWait {
            try editContext.save()
        }

        ///
        /// Make sure the notification was sent by waiting on the expectation, if already fired, this will just return.
        ///
        self.waitForExpectations(timeout: 5)
    }
}
