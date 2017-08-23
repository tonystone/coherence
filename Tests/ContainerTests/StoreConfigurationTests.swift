//
//  StoreConfigurationTests.swift
//  Coherence
//
//  Created by Tony Stone on 3/22/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import XCTest
import CoreData
@testable import Coherence

class StoreConfigurationTests: XCTestCase {

    func testInit() {
        let input = StoreConfiguration()
        let expected: (fileName: String?,
                        name: String?,
                        type: String,
                        overwriteIncompatibleStore: Bool,
                        options: [String: Any]) = (nil, nil, NSSQLiteStoreType, false, [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true])


        XCTAssertEqual(input.fileName,                   expected.fileName)
        XCTAssertEqual(input.name,                       expected.name)
        XCTAssertEqual(input.overwriteIncompatibleStore, expected.overwriteIncompatibleStore)
        XCTAssertEqual(input.options[NSInferMappingModelAutomaticallyOption] as? Bool,       expected.options[NSInferMappingModelAutomaticallyOption] as? Bool)
        XCTAssertEqual(input.options[NSMigratePersistentStoresAutomaticallyOption] as? Bool, expected.options[NSMigratePersistentStoresAutomaticallyOption] as? Bool)
     }

    func testInitWithOverrideDefaults() {
        let input = StoreConfiguration(fileName: "FileName", name: "configuration", type: NSBinaryStoreType, overwriteIncompatibleStore: true, options: [:])
        let expected: (fileName: String?,
            name: String?,
            type: String,
            overwriteIncompatibleStore: Bool,
            options: [String: Any]) = ("FileName", "configuration", NSBinaryStoreType, true, [:])


        XCTAssertEqual(input.fileName,                   expected.fileName)
        XCTAssertEqual(input.name,                       expected.name)
        XCTAssertEqual(input.overwriteIncompatibleStore, expected.overwriteIncompatibleStore)
        XCTAssertEqual(input.options.count,              expected.options.count)
    }

    func testDescription() {
        let input    = StoreConfiguration()
        let expected = "<StoreConfiguration> (type: SQLite)"

        XCTAssertEqual(input.description, expected)
    }

    func testDescriptionWithOverrideDefaults() {
        let input = StoreConfiguration(fileName: "FileName", name: "configuration", type: NSBinaryStoreType, overwriteIncompatibleStore: true, options: [:])
        let expected = "<StoreConfiguration> (fileName: 'FileName', name: 'configuration', type: Binary)"

        XCTAssertEqual(input.description, expected)
    }

    func testEqualsTrue() {
        let input = (lhs: StoreConfiguration(fileName: "FileName", name: "configuration", type: NSBinaryStoreType, overwriteIncompatibleStore: true, options: [:]),
                     rhs: StoreConfiguration(fileName: "FileName", name: "configuration", type: NSBinaryStoreType, overwriteIncompatibleStore: true, options: [:]))
        let expected = true

        XCTAssertEqual(input.lhs == input.rhs, expected)
    }

    func testEqualsFalseDifferentFileName() {
        let input = (lhs: StoreConfiguration(fileName: "FileName1", name: "configuration", type: NSBinaryStoreType, overwriteIncompatibleStore: true, options: [:]),
                     rhs: StoreConfiguration(fileName: "FileName2", name: "configuration", type: NSBinaryStoreType, overwriteIncompatibleStore: true, options: [:]))
        let expected = false

        XCTAssertEqual(input.lhs == input.rhs, expected)
    }

    func testEqualsFalseDifferentConfiguration() {
        let input = (lhs: StoreConfiguration(fileName: "FileName", name: "configuration1", type: NSBinaryStoreType, overwriteIncompatibleStore: true, options: [:]),
                     rhs: StoreConfiguration(fileName: "FileName", name: "configuration2", type: NSBinaryStoreType, overwriteIncompatibleStore: true, options: [:]))
        let expected = false

        XCTAssertEqual(input.lhs == input.rhs, expected)
    }

    func testEqualsFalseDifferentType() {
        let input = (lhs: StoreConfiguration(fileName: "FileName", name: "configuration", type: NSSQLiteStoreType, overwriteIncompatibleStore: true, options: [:]),
                     rhs: StoreConfiguration(fileName: "FileName", name: "configuration", type: NSBinaryStoreType, overwriteIncompatibleStore: true, options: [:]))
        let expected = false

        XCTAssertEqual(input.lhs == input.rhs, expected)
    }

    func testEqualsFalseDifferentOverwriteIncompatibleStore() {
        let input = (lhs: StoreConfiguration(fileName: "FileName", name: "configuration", type: NSBinaryStoreType, overwriteIncompatibleStore: true, options: [:]),
                     rhs: StoreConfiguration(fileName: "FileName", name: "configuration", type: NSBinaryStoreType, overwriteIncompatibleStore: false, options: [:]))
        let expected = false

        XCTAssertEqual(input.lhs == input.rhs, expected)
    }

    func testEqualsFalseDifferentOptions() {
        let input = (lhs: StoreConfiguration(fileName: "FileName", name: "configuration", type: NSBinaryStoreType, overwriteIncompatibleStore: true, options: [:]),
                     rhs: StoreConfiguration(fileName: "FileName", name: "configuration", type: NSBinaryStoreType, overwriteIncompatibleStore: true, options: ["Test": 1]))
        let expected = false

        XCTAssertEqual(input.lhs == input.rhs, expected)
    }
}
