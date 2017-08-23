///
///  CoreDataStackTests.swift
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
///  Created by Tony Stone on 1/15/16.
///
import XCTest
import CoreData
import Coherence

fileprivate let firstName = "First"
fileprivate let lastName  = "Last"
fileprivate let userName  = "First Last"

class ObjcPersistentContainerTests: XCTestCase {
    
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

    func testConstructionWithName() {

        let input  = "ContainerTestModel4"
        let expected = (name: input, model: TestModelLoader.load(name: "ContainerTestModel4"))

        let container = ObjcPersistentContainer(name: input)

        XCTAssertEqual(container.name,               expected.name)
        XCTAssertEqual(container.managedObjectModel, expected.model)
    }

    func testConstructionNameAndModel() {

        let input  = (name: "TestModel", model: TestModelLoader.load(name: "ContainerTestModel4"))
        let expected = input

        let container = ObjcPersistentContainer(name: input.name, managedObjectModel: input.model)

        XCTAssertEqual(container.name,               expected.name)
        XCTAssertEqual(container.managedObjectModel, expected.model)
    }
    
    func testConstructionWithDescription () {

        let input = (name: "ContainerTestModel1", model: TestModelLoader.load(name: "ContainerTestModel1"), configuration: StoreConfiguration(fileName: "ContainerTestModel1.sqlite"))
        let expected = TestPersistentStoreManager.defaultPersistentStoreDirectory().appendingPathComponent("ContainerTestModel1.sqlite")

        do {
            let container = ObjcPersistentContainer(name: input.name, managedObjectModel: input.model)

            try container.loadPersistentStores(for: [input.configuration])

            XCTAssertTrue(TestPersistentStoreManager.persistentStoreExists(url: expected))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testCRUD () throws {

        let input = (firstName: "firstName", lastName: "lastName", userName: "userName")

        let container = ObjcPersistentContainer(name: "ContainerTestModel1", managedObjectModel:  TestModelLoader.load(name: "ContainerTestModel1"))
        try container.loadPersistentStores()

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

    fileprivate func deleteIfExists(fileURL url: URL) throws {
    
        let fileManager = FileManager.default
        let path = url.path

        if fileManager.fileExists(atPath: path) {
            try fileManager.removeItem(at: url)
        }
    }
}
