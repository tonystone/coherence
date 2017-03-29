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

    func testDefaultStoreLocation() {

        let input = Connect.defaultStoreLocation()
        let expected = { () -> URL in

            let possibleURLs = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)

            return possibleURLs[0]
        }()

        XCTAssertEqual(input, expected)
    }

    func testConstructionWithModelName() {

        let input = self.testModel
        let expected = input

        XCTAssertEqual(Connect(name: modelName).managedObjectModel, expected)
    }

    func testConstructionWithModelNameAndModel() {

        let input = self.testModel
        let expected = input

        XCTAssertEqual(Connect(name: modelName, managedObjectModel: input).managedObjectModel , expected)
    }

    func testStoreConfigurations() {

        let input = (name: modelName, configuration: StoreConfiguration(url: defaultPersistentStoreDirectory().appendingPathComponent("\(modelName).sqlite")))
        let expected: (url: URL,
            name: String?,
            type: String,
            overwriteIncompatibleStore: Bool,
            options: [String: Any]) = (defaultPersistentStoreDirectory().appendingPathComponent("\(modelName).sqlite"), nil, NSSQLiteStoreType, false, [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true])


        do {
            let container = Connect(name: input.name)
            container.storeConfigurations = [input.configuration]

            try container.start()

            if container.storeConfigurations.count >= 1 {
                let configuration = container.storeConfigurations[0]

                XCTAssertEqual(configuration.url,                        expected.url)
                XCTAssertEqual(configuration.name,                       expected.name)
                XCTAssertEqual(configuration.overwriteIncompatibleStore, expected.overwriteIncompatibleStore)
                XCTAssertEqual(configuration.options[NSInferMappingModelAutomaticallyOption] as? Bool,       expected.options[NSInferMappingModelAutomaticallyOption] as? Bool)
                XCTAssertEqual(configuration.options[NSMigratePersistentStoresAutomaticallyOption] as? Bool, expected.options[NSMigratePersistentStoresAutomaticallyOption] as? Bool)
            } else {
                XCTFail()
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }


    func testStart() throws {

        let input = (modelName: modelName, model: self.testModel)
        let expected = 1

        let expectation = self.expectation(description: "Completion block called.")

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

    func testStartWithIncompatibleStore() throws {

        let input = (modelName: modelName,
                     model: self.testModel,
                     emptyModel: self.testEmptyModel,
                     descriptions: [StoreConfiguration(url: defaultPersistentStoreDirectory().appendingPathComponent("\(modelName).sqlite"), options: [NSMigratePersistentStoresAutomaticallyOption: false])])

        /// Create the first instance of the persistent stores using the empty model
        do {
            let connect = Connect(name: input.modelName, managedObjectModel: input.emptyModel)

            connect.storeConfigurations = input.descriptions
            try connect.start()
        }

        /// Now create the second instance using the real model, it should throw an exception
        let connect = Connect(name: input.modelName, managedObjectModel: input.model)
        connect.storeConfigurations = input.descriptions

        let expectation = self.expectation(description: "Completion block called with error.")

        connect.start() { (error) in
            if error == nil {
                XCTFail("Failed to throw an error.")
            }
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                XCTFail("\(error)")
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

    func testStartThrowsWithIncompatibleStore() throws {

        let input = (modelName: modelName,
                     model: self.testModel,
                     emptyModel: self.testEmptyModel,
                     descriptions: [StoreConfiguration(url: defaultPersistentStoreDirectory().appendingPathComponent("\(modelName).sqlite"), options: [NSMigratePersistentStoresAutomaticallyOption: false])])


        /// Create the first instance of the persistent stores using the empty model
        do {
            let connect =  Connect(name: input.modelName, managedObjectModel: input.emptyModel)

            connect.storeConfigurations = input.descriptions
            try connect.start()
        }

        /// Now create the second instance using the real model, it should throw an exception
        let connect = Connect(name: input.modelName, managedObjectModel: input.model)

        connect.storeConfigurations = input.descriptions

        XCTAssertThrowsError(try connect.start())
    }

    func testConnectEntityCanBeManagedUniquenessAttributesDefined() throws {

        guard let input = self.testModel.entitiesByName["ConnectEntity1"]
            else { XCTFail(); return }

        ///
        /// Note: Test values are defined on the static model.
        ///
        let expected = (managed: true, uniqnessAttributes: ["id"])

        let connect = Connect(name: modelName, managedObjectModel: self.testModel)
        try connect.start()

        XCTAssertEqual(input.managed, expected.managed)
        XCTAssertEqual(input.uniquenessAttributes, expected.uniqnessAttributes)
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
}
