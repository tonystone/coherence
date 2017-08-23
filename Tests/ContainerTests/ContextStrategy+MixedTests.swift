///
///  ContextStrategy+MixedTests.swift
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
///  Created by Tony Stone on 3/31/17.
///
import XCTest
import CoreData

@testable import Coherence

class ContextStrategyMixedTests: XCTestCase {
    
    let container = GenericPersistentContainer<ContextStrategy.Mixed>(name: "ContainerTestModel1")

    override func setUp() {
        super.setUp()

        do {
            /// Load a default store type that loads to /dev/null
            try container.attachPersistentStores(for: [StoreConfiguration(type: NSInMemoryStoreType)])
        } catch {
            XCTFail()
        }
    }

    func testViewContextUpdate() throws {

        let input = (firstName: "firstName", lastName: "lastName", userName: "userName")

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
