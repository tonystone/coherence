///
///  ContextStrategy+DirectIndependent.swift
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

class ContextStrategyIndependentDirectTests: XCTestCase {

    let container = GenericPersistentContainer<ContextStrategy.DirectIndependent>(name: "ContainerTestModel1")

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

        let input    = (firstName: "firstName", lastName: "lastName", userName: "userName")
        let expected = input

        let backgroundContext1 = container.newBackgroundContext()

        var userId: NSManagedObjectID? = nil

        backgroundContext1.performAndWait {

            if let insertedUser = NSEntityDescription.insertNewObject(forEntityName: "ContainerUser", into: backgroundContext1) as? ContainerUser {

                insertedUser.firstName = input.firstName
                insertedUser.lastName  = input.lastName
                insertedUser.userName  = input.userName

                do {
                    try backgroundContext1.save()
                } catch {
                    XCTFail()
                }
                userId = insertedUser.objectID
            }
        }

        let backgroundContext2 = container.newBackgroundContext()

        ///
        /// Now use the second background context to see if it got persisted.  
        ///
        /// Note: We use a backgroundContext instead of a viewContext because the background 
        ///       context is created after the insert so that there is no chance that it got 
        ///       updated through some other means.
        ///
        try backgroundContext2.performAndWait {

            if let userId = userId {
                let savedUser = try backgroundContext2.existingObject(with: userId)

                if let savedUser = savedUser as? ContainerUser {

                    XCTAssertTrue(savedUser.firstName == expected.firstName)
                    XCTAssertTrue(savedUser.lastName  == expected.lastName)
                    XCTAssertTrue(savedUser.userName  == expected.userName)

                } else {
                    XCTFail()
                }
            } else {
                XCTFail()
            }
        }
    }
}
