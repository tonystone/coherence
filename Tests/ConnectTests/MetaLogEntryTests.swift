//
//  MetaLogEntryTests.swift
//  Coherence
//
//  Created by Tony Stone on 1/29/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import XCTest
import Foundation
@testable import Coherence

class MetaLogEntryTests: XCTestCase {

    func testMetaLogEntryInsertDataArchive() {

        typealias TargetType = MetaLogEntry.InsertData

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

        typealias TargetType = MetaLogEntry.UpdateData

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

        typealias TargetType = MetaLogEntry.DeleteData

        let input = TargetType()

        let data = NSKeyedArchiver.archivedData(withRootObject: input)

        XCTAssert(NSKeyedUnarchiver.unarchiveObject(with: data) is TargetType)
    }

}
