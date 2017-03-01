///
///  AssociatedStorageTests.swift
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

@testable import Coherence

fileprivate var testKey: UInt8 = 0

class AssociatedStorageTests: XCTestCase {

    // MARK: - String value testing

    func testAssociatedValueString() {

        let input: (value: String, defaultValue: String) = ("Test string 4", "Default test string 4")
        let expected = "Test string 4"

        /// Set the value with the test values
        associatedValue(self, key: &testKey, value: input.value)

        XCTAssertEqual(associatedValue(self, key: &testKey, defaultValue: input.defaultValue), expected)
    }

    func testAssociatedValueStringNoSet() {

        let input    = "Default test string 5"
        let expected = "Default test string 5"

        XCTAssertEqual(associatedValue(self, key: &testKey, defaultValue: input), expected)
    }

    // MARK: - Optional String value testing

    func testAssociatedValueOptionalStringWithValue() {

        let input: (value: String?, defaultValue: String?) = ("Test string 1", "Default test string 1")
        let expected = "Test string 1"

        /// Set the value with the test values
        associatedValue(self, key: &testKey, value: input.value)

        XCTAssertEqual(associatedValue(self, key: &testKey, defaultValue: input.defaultValue), expected)
    }

    func testAssociatedValueOptionalStringWithNil() {

        let input: (value: String?, defaultValue: String?) = (nil, "Default test string 2")
        let expected = "Default test string 2"

        /// Set the value with the test values
        associatedValue(self, key: &testKey, value: input.value)

        XCTAssertEqual(associatedValue(self, key: &testKey, defaultValue: input.defaultValue), expected)
    }

    func testAssociatedValueOptionalStringNoSet() {

        let input: String?    = "Default test string 3"
        let expected: String? = "Default test string 3"

        XCTAssertEqual(associatedValue(self, key: &testKey, defaultValue: input), expected)
    }

    // MARK: - Int value testing

    func testAssociatedValueInt() {

        let input: (value: Int, defaultValue: Int) = (3, 4)
        let expected = 3

        /// Set the value with the test values
        associatedValue(self, key: &testKey, value: input.value)

        XCTAssertEqual(associatedValue(self, key: &testKey, defaultValue: input.defaultValue), expected)
    }

    func testAssociatedValueIntNoSet() {

        let input    = 5
        let expected = 5
        
        XCTAssertEqual(associatedValue(self, key: &testKey, defaultValue: input), expected)
    }

    // MARK: - Optional Int value testing
    
    func testAssociatedValueOptionalIntWithValue() {

        let input: (value: Int?, defaultValue: Int?) = (1, 2)
        let expected = 1

        /// Set the value with the test values
        associatedValue(self, key: &testKey, value: input.value)

        XCTAssertEqual(associatedValue(self, key: &testKey, defaultValue: input.defaultValue), expected)
    }

    func testAssociatedValueOptionalIntWithNil() {

        let input: (value: Int?, defaultValue: Int?) = (nil, 3)
        let expected = 3

        /// Set the value with the test values
        associatedValue(self, key: &testKey, value: input.value)

        XCTAssertEqual(associatedValue(self, key: &testKey, defaultValue: input.defaultValue), expected)
    }

    func testAssociatedValueOptionalIntNoSet() {

        let input: Int?    = 2
        let expected: Int? = 2

        XCTAssertEqual(associatedValue(self, key: &testKey, defaultValue: input), expected)
    }

    // MARK: - Multi Class testing

    func testAssociatedValueOptionalStringWithValueMultipleClasses() {

        class MockObject {}

        let input: [(value: String?, defaultValue: String?)] = [("Test string 0", "Default test string 0"), ("Test string 1", "Default test string 1")]
        let expected = ["Test string 0", "Test string 1"]

        let mock0 = MockObject()
        let mock1 = MockObject()

        /// Set the value with the test values
        associatedValue(mock0, key: &testKey, value: input[0].value)
        associatedValue(mock1, key: &testKey, value: input[1].value)

        XCTAssertEqual(associatedValue(mock0, key: &testKey, defaultValue: input[0].defaultValue), expected[0])
        XCTAssertEqual(associatedValue(mock1, key: &testKey, defaultValue: input[1].defaultValue), expected[1])
    }

    func testAssociatedValueOptionalStringWithNilMultipleClasses() {

        class MockObject {}

        let input: [(value: String?, defaultValue: String?)] = [(nil, "Default test string 0"), (nil, "Default test string 1")]
        let expected = ["Default test string 0", "Default test string 1"]

        let mock0 = MockObject()
        let mock1 = MockObject()

        /// Set the value with the test values
        associatedValue(mock0, key: &testKey, value: input[0].value)
        associatedValue(mock1, key: &testKey, value: input[1].value)

        XCTAssertEqual(associatedValue(mock0, key: &testKey, defaultValue: input[0].defaultValue), expected[0])
        XCTAssertEqual(associatedValue(mock1, key: &testKey, defaultValue: input[1].defaultValue), expected[1])
    }

    func testAssociatedValueStringWithValueMultipleClasses() {

        class MockObject {}

        let input: [(value: String, defaultValue: String)] = [("Test string 0", "Default test string 0"), ("Test string 1", "Default test string 1")]
        let expected = ["Test string 0", "Test string 1"]

        let mock0 = MockObject()
        let mock1 = MockObject()

        /// Set the value with the test values
        associatedValue(mock0, key: &testKey, value: input[0].value)
        associatedValue(mock1, key: &testKey, value: input[1].value)

        XCTAssertEqual(associatedValue(mock0, key: &testKey, defaultValue: input[0].defaultValue), expected[0])
        XCTAssertEqual(associatedValue(mock1, key: &testKey, defaultValue: input[1].defaultValue), expected[1])
    }

    func testAssociatedValueStringNoSetMultipleClasses() {

        class MockObject {}

        let input    = ["Default test string 0", "Default test string 1"]
        let expected = ["Default test string 0", "Default test string 1"]

        let mock0 = MockObject()
        let mock1 = MockObject()

        XCTAssertEqual(associatedValue(mock0, key: &testKey, defaultValue: input[0]), expected[0])
        XCTAssertEqual(associatedValue(mock1, key: &testKey, defaultValue: input[1]), expected[1])
    }


}
