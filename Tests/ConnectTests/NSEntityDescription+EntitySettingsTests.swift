///
///  NSEntityDescription+EntitySettingsTests.swift
///
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
///  Created by Tony Stone on 1/23/17.
///
import XCTest
import CoreData
@testable import Coherence

class NSEntityDescription_EntitySettingsTests: XCTestCase {

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

    func testUniquenessAttributesWithValue() {
        let input = ["attribute1", "attribute2", "attribute3"]
        let expected = input

        entity.uniquenessAttributes = input

        XCTAssertNotNil(entity.uniquenessAttributes)

        if let result = entity.uniquenessAttributes {
            XCTAssertEqual(result, expected)
        }
    }

    func testUniquenessAttributesWithNil() {
        let input: [String]? = nil

        entity.uniquenessAttributes = input

        XCTAssertNil(entity.uniquenessAttributes)
    }

    func testUniquenessAttributesWithValueThanNil() {
        let input: ([String]?,[String]?) = (["attribute1", "attribute2", "attribute3"], nil)

        entity.uniquenessAttributes = input.0
        entity.uniquenessAttributes = input.1

        XCTAssertNil(entity.uniquenessAttributes)
    }

    func testSalenessIntervalWithValue() {
        let input = 3060
        let expected = input

        entity.stalenessInterval = input

        XCTAssertEqual(entity.stalenessInterval, expected)
    }

    func testLogTransactionsWithTrue() {
        let input = true
        let expected = input

        entity.logTransactions = input

        XCTAssertEqual(entity.logTransactions, expected)
    }

    func testLogTransactionsWithFalse() {
        let input = false
        let expected = input

        entity.logTransactions = input

        XCTAssertEqual(entity.logTransactions, expected)
    }

    func testSetSettingsWithStringString() {
        let input = ["uniquenessAttributes": "attribute1, attribute2",
                     "stalenessInterval": "3600",
                     "logTransactions": "true"]
        let expected = (["attribute1", "attribute2"],
                        3600,
                        true)

        entity.setSettings(from: input)

        XCTAssertNotNil(entity.uniquenessAttributes)

        if let result = entity.uniquenessAttributes {
            XCTAssertEqual(result, expected.0)
        }

        XCTAssertEqual(entity.stalenessInterval, expected.1)
        XCTAssertEqual(entity.logTransactions, expected.2)
    }

    func testSetSettingsWithAnyHashableAny() {
        let input: [AnyHashable: Any] = ["uniquenessAttributes": ["attribute1", "attribute2"],
                     "stalenessInterval": 3600,
                     "logTransactions": true]
        let expected = (["attribute1", "attribute2"],
                        3600,
                        true)

        entity.setSettings(from: input)

        XCTAssertNotNil(entity.uniquenessAttributes)

        if let result = entity.uniquenessAttributes {
            XCTAssertEqual(result, expected.0)
        }

        XCTAssertEqual(entity.stalenessInterval, expected.1)
        XCTAssertEqual(entity.logTransactions, expected.2)
    }
    
}
