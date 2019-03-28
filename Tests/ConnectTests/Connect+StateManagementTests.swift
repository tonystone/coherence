//
//  Connect+StateManagementTests.swift
//  Coherence
//
//  Created by Tony Stone on 2/14/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import XCTest
import CoreData
@testable import Coherence

fileprivate let modelName = "ConnectTestModel"

class ConnectStateManagementTests: XCTestCase {

    let testModel      = TestModelLoader.load(name: modelName)
    let testEmptyModel = TestModelLoader.load(name: modelName + "Empty")

    override func setUp() {
        super.setUp()

        do {
            try TestPersistentStoreManager.removePersistentStoreCache()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testStart() throws {

        let input = modelName
        let expected = TestPersistentStoreManager.defaultPersistentStoreDirectory().appendingPathComponent("\(modelName)._meta.sqlite")

        let expectation = self.expectation(description: "Completion block called.")

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: input)

        connect.start() { (error) in
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5) { (error) in

            if error == nil {
                XCTAssertTrue(TestPersistentStoreManager.persistentStoreExists(url: expected))
            }
        }
        try connect.stop()  /// Clean up
    }

    func testStartThrows() throws {

        let input = (modelName: modelName, model: self.testModel)
        let expected = 1

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: input.modelName, managedObjectModel: input.model)
        try connect.start()

        XCTAssertEqual(connect.persistentStoreCoordinator.persistentStores.count, expected)

        try connect.stop()  /// Clean up
    }

    func testStart2xThrows() throws {

        let input = (modelName: modelName, model: self.testModel)
        let expected = 1

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: input.modelName, managedObjectModel: input.model)
        try connect.start()
        try connect.start() /// Calling start a second time should be a no-op

        XCTAssertEqual(connect.persistentStoreCoordinator.persistentStores.count, expected)

        try connect.stop()  /// Clean up
    }

    func testStop() throws {

        let input = (modelName: modelName, isSuspended: true)

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: input.modelName)
        try connect.start()
        try connect.stop()
    }

    func testStopWithCompletionBlock() throws {

        let input = modelName
        let expected = 0

        let expectation = self.expectation(description: "Completion block called.")

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: input)
        try connect.start()

        connect.stop() { (error) in
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5) { (error) in

            if error == nil {
                XCTAssertEqual(connect.persistentStoreCoordinator.persistentStores.count, expected)
            }
        }
        try connect.stop()  /// Clean up
    }

    func testStartStopStart() throws {

        let input = (modelName: modelName, isSuspended: true)

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: input.modelName)
        try connect.start()
        try connect.stop()
        try connect.start()
        try connect.stop()  /// Clean up
    }

    func testStartStoppedTwice() throws {

        let input = (modelName: modelName, isSuspended: true)

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: input.modelName)
        try connect.start()
        try connect.stop()
        try connect.stop()
    }

    func testQueueStateAfterInitIsNotSuspended() throws {

        let input = modelName
        let expected = false

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: input)
        try connect.start()

        XCTAssertEqual(connect.suspended, expected)

        try connect.stop()  /// Clean up
    }

    func testQueueStateIfNotStarted() {

        let input = modelName
        let expected = false

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: input)

        XCTAssertEqual(connect.suspended, expected)
    }

    func testQueueStateAfterStartIsNotSuspended() throws {

        let input = modelName
        let expected = false

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: input)
        try connect.start()

        XCTAssertEqual(connect.suspended, expected)

        try connect.stop()  /// Clean up
    }

    func testSuspendedAfterStartUp() throws {

        let input = (modelName: modelName, isSuspended: true)
        let expected = input.isSuspended

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: input.modelName)
        try connect.start()
        connect.suspended = input.isSuspended

        XCTAssertEqual(connect.suspended, expected)

        try connect.stop()  /// Clean up
    }

#if os(iOS)
    func testProtectedDataWillBecomeUnavailable() throws {

        let input = (modelName: modelName, isSuspended: true)
        let expected = input.isSuspended

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: input.modelName)
        try connect.start()

        NotificationCenter.default.post(name: UIApplication.protectedDataWillBecomeUnavailableNotification, object: nil)

        XCTAssertEqual(connect.suspended, expected)

        try connect.stop()  /// Clean up
    }

    func testProtectedDataDidBecomeAvailable() throws {

        let input = (modelName: modelName, isSuspended: true)
        let expected = false

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: input.modelName)
        try connect.start()
        connect.suspended = input.isSuspended

        NotificationCenter.default.post(name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)

        XCTAssertEqual(connect.suspended, expected)

        try connect.stop()  /// Clean up
    }
#endif
}
