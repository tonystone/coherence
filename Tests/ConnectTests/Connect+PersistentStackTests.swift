//
//  Connect+PersistentStackTests.swift
//  Coherence
//
//  Created by Tony Stone on 8/17/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import XCTest
import CoreData
@testable import Coherence

fileprivate let modelName = "ConnectTestModel"

class ConnectPersistentStackTests: XCTestCase {

    let testModel      = TestModelLoader.load(name: modelName)
    let testEmptyModel = TestModelLoader.load(name: modelName + "Empty")

    override func setUp() {
        super.setUp()

        do {
            try TestPersistentStoreManager.removePersistentStoreCache()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testAttachPersistentStoreWithConfiguration() throws {

        let input = (modelName: modelName, model: TestModelLoader.load(name: modelName), configuration: StoreConfiguration())

        let connect = GenericConnect<ContextStrategy.Mixed>(name: input.modelName, managedObjectModel: input.model)

        do {
            let _ = try connect.attachPersistentStore(for: input.configuration)

            XCTAssertTrue(TestPersistentStoreManager.persistentStoreExists(storePrefix: modelName, storeType: NSSQLiteStoreType))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testAttachPersistentStoresWithMultipleConfiguration() throws {

        let input = (modelName: modelName, model: TestModelLoader.load(name: modelName),
                     configurations: [StoreConfiguration(name: "TransientEntities"),
                                      StoreConfiguration(name: "PersistentEntities")])

        let connect = GenericConnect<ContextStrategy.Mixed>(name: input.modelName, managedObjectModel: input.model)

        do {
            let _ = try connect.attachPersistentStore(for: input.configurations[0])
            let _ = try connect.attachPersistentStore(for: input.configurations[1])

            XCTAssertTrue(TestPersistentStoreManager.persistentStoreExists(storePrefix: modelName, storeType: NSSQLiteStoreType, configuration: "TransientEntities"))
            XCTAssertTrue(TestPersistentStoreManager.persistentStoreExists(storePrefix: modelName, storeType: NSSQLiteStoreType, configuration: "PersistentEntities"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testAttachPersistentStoreAfterStart() throws {

        let input = (modelName: modelName, model: TestModelLoader.load(name: modelName),
                     configurations: [StoreConfiguration(name: "TransientEntities"),
                                      StoreConfiguration(name: "PersistentEntities")])

        let connect = GenericConnect<ContextStrategy.Mixed>(name: input.modelName, managedObjectModel: input.model)

        do {
            let _ = try connect.attachPersistentStore(for: input.configurations[0])

            try connect.start()

            let _ = try connect.attachPersistentStore(for: input.configurations[1])

            XCTAssertTrue(TestPersistentStoreManager.persistentStoreExists(storePrefix: modelName, storeType: NSSQLiteStoreType, configuration: "TransientEntities"))
            XCTAssertTrue(TestPersistentStoreManager.persistentStoreExists(storePrefix: modelName, storeType: NSSQLiteStoreType, configuration: "PersistentEntities"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testDetachPersistentStore() throws {

        let input = (modelName: modelName, model: TestModelLoader.load(name: modelName), configuration: StoreConfiguration())

        let connect = GenericConnect<ContextStrategy.Mixed>(name: input.modelName, managedObjectModel: input.model)

        do {
            let testStore = try connect.attachPersistentStore(for: input.configuration)

            XCTAssertTrue(connect.persistentStoreCoordinator.persistentStores.contains(testStore))

            try connect.detach(persistentStore: testStore)

            XCTAssertFalse(connect.persistentStoreCoordinator.persistentStores.contains(testStore))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testAttachPersistentStoreWithIncompatibleStore() throws {

        let input = (modelName: modelName,
                     model: self.testModel,
                     emptyModel: self.testEmptyModel,
                     storeConfiguration: StoreConfiguration(fileName: "\(modelName).sqlite", overwriteIncompatibleStore: false, options: [NSMigratePersistentStoresAutomaticallyOption: false]))

        /// Create the first instance of the persistent stores using the empty model
        do {
            let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: input.modelName, managedObjectModel: input.emptyModel)

            try connect.attachPersistentStore(for: input.storeConfiguration)
        }

        /// Now create the second instance using the real model, it should throw an exception
        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: input.modelName, managedObjectModel: input.model)

        XCTAssertThrowsError(try connect.attachPersistentStore(for: input.storeConfiguration))
    }

    func testAttachPersistentStoresWithConfigurations() throws {

        let input = (modelName: modelName, model: TestModelLoader.load(name: modelName), configuration: StoreConfiguration())

        let connect = GenericConnect<ContextStrategy.Mixed>(name: input.modelName, managedObjectModel: input.model)

        do {
            let _ = try connect.attachPersistentStores(for: [input.configuration])

            XCTAssertTrue(TestPersistentStoreManager.persistentStoreExists(storePrefix: modelName, storeType: NSSQLiteStoreType))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testAttachPersistentStoresWithIncompatibleStore() throws {

        let input = (modelName: modelName,
                     model: self.testModel,
                     emptyModel: self.testEmptyModel,
                     storeConfigurations: [StoreConfiguration(fileName: "\(modelName).sqlite", overwriteIncompatibleStore: false, options: [NSMigratePersistentStoresAutomaticallyOption: false])])

        /// Create the first instance of the persistent stores using the empty model
        do {
            let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: input.modelName, managedObjectModel: input.emptyModel)

            try connect.attachPersistentStores(for: input.storeConfigurations)
        }

        /// Now create the second instance using the real model, it should throw an exception
        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: input.modelName, managedObjectModel: input.model)

        XCTAssertThrowsError(try connect.attachPersistentStores(for: input.storeConfigurations))
    }

    func testDetachPersistentStores() throws {

        let input = (modelName: modelName, model: TestModelLoader.load(name: modelName), configuration: StoreConfiguration())

        let connect = GenericConnect<ContextStrategy.Mixed>(name: input.modelName, managedObjectModel: input.model)

        do {
            let testStore = try connect.attachPersistentStore(for: input.configuration)

            XCTAssertTrue(connect.persistentStoreCoordinator.persistentStores.contains(testStore))

            try connect.detach(persistentStores: [testStore])

            XCTAssertFalse(connect.persistentStoreCoordinator.persistentStores.contains(testStore))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

}
