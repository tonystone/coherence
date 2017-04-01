///
///  ManagedObject+ExtensionsTests.swift
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
///  Created by Tony Stone on 2/28/17.
///
import Foundation
import XCTest
import CoreData

@testable import Coherence

///
/// Main testing class
///
class ManagedObjectExtensionsTests: XCTestCase {

    let connect = Connect<ContextStrategy.Mixed>(name: "ConnectTestModel")

    override func setUp() {
        super.setUp()

        do {
            try connect.start()
        } catch {
            XCTFail()
        }
    }

    func testUniguenessIDString() throws {
    
        let input    = (id: Int64(1), string: "Test String")
        let expected = "1Test String"

        let context = connect.newBackgroundContext()

        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: ConnectEntity2.self), in: context) else {
            XCTFail()
            return
        }

        let object = ConnectEntity2(entity: entity, insertInto: context)
        object.id = input.id
        object.stringAttribute = input.string

        /// Reset the uniqueness attributes to a composite key for testing.
        entity.uniquenessAttributes = [#keyPath(ConnectEntity2.id), #keyPath(ConnectEntity2.stringAttribute)]

        XCTAssertEqual(object.uniqueueIDString(), expected)
    }

    func testUniguenessIDStringWithNilOptional() throws {

        let input: (id: Int64, string: String?) = (Int64(1), nil)
        let expected = "1"

        let context = connect.newBackgroundContext()

        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: ConnectEntity2.self), in: context) else {
            XCTFail()
            return
        }

        let object = ConnectEntity2(entity: entity, insertInto: context)
        object.id = input.id
        object.stringAttribute = input.string

        /// Reset the uniqueness attributes to a composite key for testing.
        entity.uniquenessAttributes = [#keyPath(ConnectEntity2.id), #keyPath(ConnectEntity2.stringAttribute)]

        XCTAssertEqual(object.uniqueueIDString(), expected)
    }

    func testUniguenessIDStringWithEmptyUniquenessAttributes() throws {

        let expected: String? = nil

        let context = connect.newBackgroundContext()

        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: ConnectEntity3Unmanaged.self), in: context) else {
            XCTFail()
            return
        }
        let mockManagedObject = ConnectEntity3Unmanaged(entity: entity, insertInto: context)

        XCTAssertEqual(mockManagedObject.uniqueueIDString(), expected)
    }
}
