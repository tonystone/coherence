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
        let expected: (url: URL?,
                        name: String?,
                        type: String,
                        overwriteIncompatibleStore: Bool,
                        options: [String: Any]) = (nil, nil, NSSQLiteStoreType, false, [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true])

        XCTAssertEqual(input.url,                        expected.url)
        XCTAssertEqual(input.name,                       expected.name)
        XCTAssertEqual(input.overwriteIncompatibleStore, expected.overwriteIncompatibleStore)
        XCTAssertEqual(input.options[NSInferMappingModelAutomaticallyOption] as? Bool,       expected.options[NSInferMappingModelAutomaticallyOption] as? Bool)
        XCTAssertEqual(input.options[NSMigratePersistentStoresAutomaticallyOption] as? Bool, expected.options[NSMigratePersistentStoresAutomaticallyOption] as? Bool)
     }

    func testURLWithNilValue() {
        let input: URL? = nil
        let expected = input

        var configuration = StoreConfiguration()
        configuration.url = input

        XCTAssertEqual(configuration.url, expected)
    }

    func testDescription() {
        let input    = StoreConfiguration()
        let expected = "<StoreConfiguration> (type: SQLite, url: nil)"

        XCTAssertEqual(input.description, expected)
    }

    func testDescriptionWithURL() {
        let input: URL? = URL(fileURLWithPath: "/dev/null")
        let expected = "<StoreConfiguration> (type: SQLite, url: /dev/null)"

        var configuration = StoreConfiguration()
        configuration.url = input

        XCTAssertEqual(configuration.description, expected)
    }

}
