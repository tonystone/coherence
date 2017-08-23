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

    let testModel = TestModelLoader.load(name: modelName)

    override func setUp() {
        super.setUp()

        do {
            try TestPersistentStoreManager.removePersistentStoreCache()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testDefaultStoreLocation() {

        let input = GenericConnect<ContextStrategy.Mixed>.defaultStoreLocation()
        let expected = { () -> URL in

            let possibleURLs = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)

            return possibleURLs[0]
        }()

        XCTAssertEqual(input, expected)
    }

    func testConstructionWithModelName() {

        let input = self.testModel
        let expected = input

        XCTAssertEqual(GenericConnect<ContextStrategy.Mixed>(name: modelName).managedObjectModel, expected)
    }

    func testConstructionWithModelNameAndModel() {

        let input = self.testModel
        let expected = input

        XCTAssertEqual(GenericConnect<ContextStrategy.Mixed>(name: modelName, managedObjectModel: input).managedObjectModel , expected)
    }

    func testConnectEntityCanBeManagedUniquenessAttributesDefined() throws {

        guard let input = self.testModel.entitiesByName["ConnectEntity1"]
            else { XCTFail(); return }

        ///
        /// Note: Test values are defined on the static model.
        ///
        let expected = (managed: true, uniqnessAttributes: ["id"])

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: modelName, managedObjectModel: self.testModel)
        try connect.start()

        XCTAssertEqual(input.managed, expected.managed)
        XCTAssertEqual(input.uniquenessAttributes, expected.uniqnessAttributes)
    }

    func testConnectMissingUniquenessAttributeEntityCannotBeManaged() throws {

        let input = self.testModel.entitiesByName["ConnectEntity4MissingUniquenessAttribute"]
        let expected = false

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: modelName, managedObjectModel: self.testModel)
        try connect.start()

        XCTAssertEqual(input?.managed, expected)
    }

    func testPersistentStoreCoordinator() {

        do {
            let input = (id: Int64(1), string: "Test String 1")
            let expected = input

            let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: modelName, managedObjectModel: self.testModel)

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

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: modelName, managedObjectModel: self.testModel)

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

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: modelName, managedObjectModel: self.testModel)

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

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: modelName, managedObjectModel: self.testModel)

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
