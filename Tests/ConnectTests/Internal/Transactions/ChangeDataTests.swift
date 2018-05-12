//
//  ChangeDataTests.swift
//  Coherence
//
//  Created by Tony Stone on 5/12/18.
//  Copyright © 2018 Tony Stone. All rights reserved.
//

import XCTest

@testable import Coherence

class ChangeDataTests: XCTestCase {

    func testInit() {
        XCTAssertNotNil(ChangeData())
    }

    func testArchive() {

        let input = ChangeData()

        let data = NSKeyedArchiver.archivedData(withRootObject: input)
        let result = NSKeyedUnarchiver.unarchiveObject(with: data)

        XCTAssert(result is ChangeData, "Invalid type conversion")
    }
}

class InsertDataTests: XCTestCase {

    func testInit() {
        XCTAssertNotNil(InsertData())
    }

    func testArchive() {

        let input = { () -> InsertData in

            let value = InsertData()
            value.attributesAndValues = ["col1": "value1", "col2": "value2"]
            return value
        }()
        let expected = ["col1": "value1", "col2": "value2"]

        let data = NSKeyedArchiver.archivedData(withRootObject: input)

        if let result = NSKeyedUnarchiver.unarchiveObject(with: data) as? InsertData,
           let attributesAndValues = result.attributesAndValues {

            XCTAssertTrue(attributesAndValues.elementsEqual(expected, by: { (lhs, rhs) -> Bool in
                guard let lhsKey = lhs.key as? String,
                    let lhsValue = lhs.value as? String
                    else { return false }

                return lhsKey == rhs.key && lhsValue == rhs.value
            }))
        } else {
            XCTFail("Could not unarchive InsertData.")
        }
    }

    func testDescription() {
        let input = { () -> InsertData in

            let value = InsertData()
            value.attributesAndValues = ["key1": 1, "key2": 2]
            return value
        }()
        let expected = "InsertData \\{ attributesAndValues: \\[AnyHashable\\(\"key[12]\"\\): [12], AnyHashable\\(\"key[12]\"\\): [12]\\] \\}"

        XCTAssert(input.description.range(of: expected, options: .regularExpression) != nil)
    }
}

class UpdateDataTests: XCTestCase {

    func testInit() {
        XCTAssertNotNil(UpdateData())
    }

    func testArchive() {

        let input = { () -> UpdateData in

            let value = UpdateData()
            value.attributesAndValues = ["col1": "value1", "col2": "value2"]
            value.updatedAttributes = ["col1", "col2"]
            return value
        }()
        let expected = (["col1": "value1", "col2": "value2"], ["col1", "col2"])

        let data = NSKeyedArchiver.archivedData(withRootObject: input)

        if let result = NSKeyedUnarchiver.unarchiveObject(with: data) as? UpdateData,
            let attributesAndValues = result.attributesAndValues,
            let updatedAttributes   = result.updatedAttributes {

            XCTAssertTrue(attributesAndValues.elementsEqual(expected.0, by: { (lhs, rhs) -> Bool in
                guard let lhsKey = lhs.key as? String,
                    let lhsValue = lhs.value as? String
                    else { return false }

                return lhsKey == rhs.key && lhsValue == rhs.value
            }))
            XCTAssertTrue(updatedAttributes.elementsEqual(expected.1))
        } else {
            XCTFail("Could not unarchive InsertData.")
        }
    }

    func testDescription() {
        let input = { () -> UpdateData in

            let value = UpdateData()
            value.attributesAndValues = ["key1": 1, "key2": 2]
            value.updatedAttributes = ["key1", "key2"]
            return value
        }()
        let expected = "UpdateData \\{ attributesAndValues: \\[AnyHashable\\(\"key[12]\"\\): [12], AnyHashable\\(\"key[12]\"\\): [12]\\], updatedAttributes: \\[\"key1\", \"key2\"\\] \\}"

        XCTAssert(input.description.range(of: expected, options: .regularExpression) != nil)
    }
}

class DeleteDataTests: XCTestCase {

    func testInit() {
        XCTAssertNotNil(DeleteData())
    }

    func testArchive() {

        let input = DeleteData()

        let data = NSKeyedArchiver.archivedData(withRootObject: input)
        let result = NSKeyedUnarchiver.unarchiveObject(with: data)

        XCTAssert(result is ChangeData, "Invalid type conversion")
    }

    func testDescription() {
        let input = DeleteData()
        let expected = "DeleteData {}"

        XCTAssertEqual(input.description, expected)
    }
}
