//
//  StoreConfiguration+ResolveTests.swift
//  Coherence
//
//  Created by Tony Stone on 8/18/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import XCTest
import CoreData
@testable import Coherence

class StoreConfigurationResolveTests: XCTestCase {

    func testResolveURLWithInMemoryType() {
        let input = (defaultStorePrefix: "Prefix", storeLocation: URL(fileURLWithPath: "/test/path"), configuration: StoreConfiguration(type: NSInMemoryStoreType))
        let expected: URL? = nil

        XCTAssertEqual(input.configuration.resolveURL(defaultStorePrefix: input.defaultStorePrefix, storeLocation: input.storeLocation), expected)
    }

    func testResolveURLWithInMemoryTypeAndFileName() {
        let input = (defaultStorePrefix: "Prefix", storeLocation: URL(fileURLWithPath: "/test/path"), configuration: StoreConfiguration(fileName: "TestFile", type: NSInMemoryStoreType))
        let expected: URL? = nil

        XCTAssertEqual(input.configuration.resolveURL(defaultStorePrefix: input.defaultStorePrefix, storeLocation: input.storeLocation), expected)
    }

    func testResolveURLWithSQLiteType() {
        let input = (defaultStorePrefix: "DefaultPrefix", storeLocation: URL(fileURLWithPath: "/test/path"), configuration: StoreConfiguration(type: NSSQLiteStoreType))
        let expected: URL? = URL(fileURLWithPath: "/test/path/DefaultPrefix.sqlite")

        XCTAssertEqual(input.configuration.resolveURL(defaultStorePrefix: input.defaultStorePrefix, storeLocation: input.storeLocation), expected)
    }

    func testResolveURLWithSQLiteTypeAndConfigurationName() {
        let input = (defaultStorePrefix: "DefaultPrefix", storeLocation: URL(fileURLWithPath: "/test/path"), configuration: StoreConfiguration(name: "configuration", type: NSSQLiteStoreType))
        let expected: URL? = URL(fileURLWithPath: "/test/path/DefaultPrefix.configuration.sqlite")

        XCTAssertEqual(input.configuration.resolveURL(defaultStorePrefix: input.defaultStorePrefix, storeLocation: input.storeLocation), expected)
    }

    func testResolveURLWithSQLiteTypeAndFileName() {
        let input = (defaultStorePrefix: "Prefix", storeLocation: URL(fileURLWithPath: "/test/path"), configuration: StoreConfiguration(fileName: "TestFile.ext", type: NSSQLiteStoreType))
        let expected: URL? = URL(fileURLWithPath: "/test/path/TestFile.ext")

        XCTAssertEqual(input.configuration.resolveURL(defaultStorePrefix: input.defaultStorePrefix, storeLocation: input.storeLocation), expected)
    }

    func testStoreURLWithSQLiteType() {
        let input: (prefix: String, configuration: String?, type: String, location:  URL) = ("Test", nil, NSSQLiteStoreType, URL(fileURLWithPath: "/test/path"))
        let expected = URL(fileURLWithPath: "/test/path/Test.sqlite")

        XCTAssertEqual(StoreConfiguration.storeURL(prefix: input.prefix, configuration: input.configuration, type: input.type, location: input.location), expected)
    }

    func testStoreURLWithSQLiteTypeAndConfiguration() {
        let input: (prefix: String, configuration: String?, type: String, location:  URL) = ("Test", "configuration", NSSQLiteStoreType, URL(fileURLWithPath: "/test/path"))
        let expected = URL(fileURLWithPath: "/test/path/Test.configuration.sqlite")

        XCTAssertEqual(StoreConfiguration.storeURL(prefix: input.prefix, configuration: input.configuration, type: input.type, location: input.location), expected)
    }

    func testStoreURLWithBinaryType() {
        let input: (prefix: String, configuration: String?, type: String, location:  URL) = ("Test", nil, NSBinaryStoreType, URL(fileURLWithPath: "/test/path"))
        let expected = URL(fileURLWithPath: "/test/path/Test.binary")

        XCTAssertEqual(StoreConfiguration.storeURL(prefix: input.prefix, configuration: input.configuration, type: input.type, location: input.location), expected)
    }
}
