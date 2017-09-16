///
///  MetaLogEntryTests.swift
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
///  Created by Tony Stone on 1/29/17.
///
import XCTest
import Foundation
@testable import Coherence

class MetaLogEntryTests: XCTestCase {

    func testMetaLogEntryInsertDataArchive() {

        typealias TargetType = InsertData

        let input: [String: Int] = ["key1": 1, "key2": 2]
        let expected = input

        let updateData = TargetType()
        updateData.attributesAndValues = input


        let data = NSKeyedArchiver.archivedData(withRootObject: updateData)
        let result = NSKeyedUnarchiver.unarchiveObject(with: data)

        if let result = result as? TargetType {

            if let attributesAndValues = result.attributesAndValues as? [String: Int] {

                XCTAssertEqual(attributesAndValues, expected)
            } else {
                XCTFail("Result is not the correct type of '\(String(describing: [String: Int].self))'.")
            }
        } else {
            XCTFail("Result is not the correct type of '\(String(describing: TargetType.self))'.")
        }
    }

    func testMetaLogEntryUpdateDataArchive() {

        typealias TargetType = UpdateData

        let input: ([String: Int], [String]) = (["key1": 1, "key2": 2], ["key2"])
        let expected = input

        let updateData = TargetType()
        updateData.attributesAndValues = input.0
        updateData.updatedAttributes   = input.1

        let data = NSKeyedArchiver.archivedData(withRootObject: updateData)
        let result = NSKeyedUnarchiver.unarchiveObject(with: data)

        if let result = result as? TargetType {

            if let attributesAndValues = result.attributesAndValues as? [String: Int] {

                XCTAssertEqual(attributesAndValues, expected.0)
            } else {
                XCTFail("Result is not the correct type of '\(String(describing: [String: Int].self))'.")
            }

            if let updatedAttributes = result.updatedAttributes {

                XCTAssertEqual(updatedAttributes, expected.1)
            } else {
                XCTFail("Result is not the correct type of '\(String(describing: [String].self))'.")
            }

        } else {
            XCTFail("Result is not the correct type of '\(String(describing: TargetType.self))'.")
        }
    }

    func testMetaLogEntryDeleteDataArchive() {

        typealias TargetType = DeleteData

        let input = TargetType()

        let data = NSKeyedArchiver.archivedData(withRootObject: input)

        XCTAssert(NSKeyedUnarchiver.unarchiveObject(with: data) is TargetType)
    }

    func testMetaLogEntryInsertDataDescription() {

        typealias TargetType = InsertData

        let input: [String: Int] = ["key1": 1, "key2": 2]
        let expected = "InsertData \\{ attributesAndValues: \\[AnyHashable\\(\"key[12]\"\\): [12], AnyHashable\\(\"key[12]\"\\): [12]\\] \\}"

        let updateData = TargetType()
        updateData.attributesAndValues = input

        XCTAssert(updateData.description.range(of: expected, options: .regularExpression) != nil)
    }

    func testMetaLogEntryInsertDataDescriptionNilAttributesAndValues() {

        typealias TargetType = InsertData

        let input: [String: Int]? = nil
        let expected = "InsertData { attributesAndValues: nil }"

        let updateData = TargetType()
        updateData.attributesAndValues = input

        XCTAssertEqual(updateData.description, expected)
    }

    func testMetaLogEntryUpdateDataDescription() {

        typealias TargetType = UpdateData

        let input: ([String: Int], [String]) = (["key1": 1, "key2": 2], ["key2"])
        let expected = "UpdateData \\{ attributesAndValues: \\[AnyHashable\\(\"key[12]\"\\): [12], AnyHashable\\(\"key[12]\"\\): [12]\\] updatedAttributes: \\[\"key[12]\"\\] \\}"

        let updateData = TargetType()
        updateData.attributesAndValues = input.0
        updateData.updatedAttributes   = input.1

        XCTAssert(updateData.description.range(of: expected, options: .regularExpression) != nil)
    }

    func testMetaLogEntryUpdateDataDescriptionNilAttributesAndValues() {

        typealias TargetType = UpdateData

        let input: ([String: Int]?, [String]?) = (nil, nil)
        let expected = "UpdateData { attributesAndValues: nil updatedAttributes: nil }"

        let updateData = TargetType()
        updateData.attributesAndValues = input.0
        updateData.updatedAttributes   = input.1

        XCTAssertEqual(updateData.description, expected)
    }

    func testMetaLogEntryDeleteDataDescription() {

        typealias TargetType = DeleteData

        let input = TargetType()
        let expected = "DeleteData {}"

        XCTAssertEqual(input.description, expected)
    }
}
