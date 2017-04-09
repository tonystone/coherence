//
//  ConfigurationTests.swift
//  Coherence
//
//  Created by Tony Stone on 4/8/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import XCTest
import CoreData

@testable import Coherence

class ConfigurationTests: XCTestCase {

    func testInitWithNoParameters() {
        let input = Configuration()
        let expected: (location: URL, storeConfigurations: [StoreConfiguration]) = (URL(fileURLWithPath: "/dev/null"), [])

        XCTAssertEqual(input.location, expected.location)
        XCTAssert(input.storeConfigurations.elementsEqual(expected.storeConfigurations) { (config1, config2) -> Bool in
            return config1 == config2
        })
    }

    func testInitWithLocation() {
        let input = Configuration(location: URL(fileURLWithPath: "/test/path"))
        let expected = URL(fileURLWithPath: "/test/path")

        XCTAssertEqual(input.location, expected)
    }

    func testInitWithStoreLocations() {
        let input = Configuration(storeConfigurations: [StoreConfiguration(type: NSInMemoryStoreType)])
        let expected = [StoreConfiguration(type: NSInMemoryStoreType)]

        XCTAssert(input.storeConfigurations.elementsEqual(expected) { (config1, config2) -> Bool in
            return config1 == config2
        })
    }

    func testConfigurationResolvedWithDefaultLocation() {
        let input    = URL(fileURLWithPath: "/test/path")
        let expected = Configuration(location: URL(fileURLWithPath: "/test/path"))

        let configuration = Configuration()
        let resolved = configuration.resolved(defaultLocation: input)

        XCTAssertEqual(resolved.location, expected.location)
    }

    func testConfigurationResolvedWithLocation() {
        let input    = (location: URL(fileURLWithPath: "/test/path"), defaultLocation: URL(fileURLWithPath: "/test/default"))
        let expected = Configuration(location: URL(fileURLWithPath: "/test/path"))

        let configuration = Configuration(location: input.location)
        let resolved = configuration.resolved(defaultLocation: input.defaultLocation)

        XCTAssertEqual(resolved.location, expected.location)
    }

    func testStoreConfigurationResolvedWithInMemoryType() {
        let input    = (defaultLocation: URL(fileURLWithPath: "/test/path"), type: NSInMemoryStoreType)
        let expected = StoreConfiguration(url: nil, type: NSInMemoryStoreType)

        let storeConfiguration = StoreConfiguration(type: input.type)
        let resolved = storeConfiguration.resolved(defaultLocation: input.defaultLocation)

        XCTAssertEqual(resolved, expected)
    }

    func testStoreConfigurationResolvedWithSQLiteType() {
        let input    = (defaultLocation: URL(fileURLWithPath: "/test/path"), type: NSSQLiteStoreType)
        let expected = StoreConfiguration(url: URL(fileURLWithPath: "/test/path/default.sqlite"), type: NSSQLiteStoreType)

        let storeConfiguration = StoreConfiguration(type: input.type)
        let resolved = storeConfiguration.resolved(defaultLocation: input.defaultLocation)

        XCTAssertEqual(resolved, expected)
    }

    func testStoreConfigurationResolvedWithSQLiteTypeAndName() {
        let input    = (defaultLocation: URL(fileURLWithPath: "/test/path"), name: "TestName", type: NSSQLiteStoreType)
        let expected = StoreConfiguration(url: URL(fileURLWithPath: "/test/path/testname.sqlite"), name: "TestName", type: NSSQLiteStoreType)

        let storeConfiguration = StoreConfiguration(name: input.name, type: input.type)
        let resolved = storeConfiguration.resolved(defaultLocation: input.defaultLocation)

        XCTAssertEqual(resolved, expected)
    }

    func testDescription() {
        let input    = Configuration()
        let expected = "<Configuration> (location: default, storeConfigurations: [])"

        XCTAssertEqual(input.description, expected)
    }

    func testDescriptionWithURL() {
        let input = Configuration(location: URL(fileURLWithPath: "/test/path"))
        let expected = "<Configuration> (location: /test/path, storeConfigurations: [])"

        XCTAssertEqual(input.description, expected)
    }
}

extension StoreConfiguration: Equatable {}

public func == (lhs: StoreConfiguration, rhs: StoreConfiguration) -> Bool {
    return lhs.url == rhs.url &&
        lhs.name == rhs.name &&
        lhs.type == rhs.type &&
        lhs.overwriteIncompatibleStore == rhs.overwriteIncompatibleStore
}
