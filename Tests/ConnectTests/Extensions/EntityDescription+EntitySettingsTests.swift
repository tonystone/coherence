///
///  NSEntityDescription+EntitySettingsTests.swift
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
///  Created by Tony Stone on 1/23/17.
///
import XCTest
import CoreData
@testable import Coherence

class EntityDescriptionEntitySettingsTests: XCTestCase {

    let entity = NSEntityDescription()

    override func setUp() {
        entity.name = "TestEntity"
    }

    func testManagedWithTrue() {
        let input = true
        let expected = input

        entity.managed = input

        XCTAssertEqual(entity.managed, expected)
    }

    func testManagedWithFalse() {
        let input = false
        let expected = input

        entity.managed = input

        XCTAssertEqual(entity.managed, expected)
    }

    func testUniquenessAttributes() {
        let input = ["attribute1", "attribute2", "attribute3"]
        let expected = input

        entity.uniquenessAttributes = input

        XCTAssertEqual(entity.uniquenessAttributes, expected)
    }


    func testSetSettingsWithStringString() {
        let input = ["uniquenessAttributes": "attribute1, attribute2"]
        let expected = (["attribute1", "attribute2"],
                        3600,
                        true)

        entity.setSettings(from: input)

        XCTAssertEqual(entity.uniquenessAttributes, expected.0)
    }

    func testSetSettingsWithAnyHashableAny() {
        let input: [AnyHashable: Any] = ["uniquenessAttributes": ["attribute1", "attribute2"]]
        let expected = (["attribute1", "attribute2"],
                        3600,
                        true)

        entity.setSettings(from: input)

        XCTAssertEqual(entity.uniquenessAttributes, expected.0)
    }
}
