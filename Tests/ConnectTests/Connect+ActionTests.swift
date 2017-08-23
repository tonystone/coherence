///
///  Connect+ActionTests.swift
///  Coherence
///
///  Created by Tony Stone on 3/3/17.
///  Copyright © 2017 Tony Stone. All rights reserved.
///
import XCTest
import CoreData
@testable import Coherence

fileprivate let modelName = "ConnectTestModel"

class ConnectActionTests: XCTestCase {

    override func setUp() {
        super.setUp()

        do {
            try TestPersistentStoreManager.removePersistentStoreCache()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    // MARK: GenericAction Execute Tests

    func testExecuteGenericAction()  {

        let input = MockGenericAction()
        let expected = (state: ActionState.finished, completionStatus: ActionCompletionStatus.successful)

        do {
            let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)

            try connect.start()

            let expecation = self.expectation(description: "GenericAction Completion Block Gets Called")

            let proxy = try connect.execute(input) { _ in
                expecation.fulfill()
            }

            self.waitForExpectations(timeout: 5) { error in
                if let error = error {
                    XCTFail("waitForExpectationsWithTimeout errored: \(error)")
                } else {

                    XCTAssertEqual(proxy.state,            expected.state)
                    XCTAssertEqual(proxy.completionStatus, expected.completionStatus)
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testExecuteGenericActionNoCompletionBlock()  {

        let input = MockGenericAction()
        let expected = (state: ActionState.finished, completionStatus: ActionCompletionStatus.successful)

        do {
            let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)

            try connect.start()

            self.expectation(forNotification: Coherence.Notification.ActionDidFinishExecuting.rawValue, object: nil)

            let proxy = try connect.execute(input)

            self.waitForExpectations(timeout: 5) { error in
                if let error = error {
                    XCTFail("waitForExpectationsWithTimeout errored: \(error)")
                } else {

                    XCTAssertEqual(proxy.state,            expected.state)
                    XCTAssertEqual(proxy.completionStatus, expected.completionStatus)
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testExecuteGenericActionThrowingAnError() throws {

        let input = MockGenericAction(forceError: true)
        let expected = (state: ActionState.finished, completionStatus: ActionCompletionStatus.failed)

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
        try connect.start()

        let expecation = self.expectation(description: "GenericAction Completion Block Gets Called")

        let proxy = try connect.execute(input) { (proxy) in

            if proxy.error == nil {
                XCTFail("No error thrown.")
            }
            expecation.fulfill()
        }

        self.waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            } else {

                XCTAssertEqual(proxy.state,            expected.state)
                XCTAssertEqual(proxy.completionStatus, expected.completionStatus)
            }
        }
    }

    // MARK: GenericAction Cancel Tests

    func testCancelGenericActionBeforeExecuted() throws {

        let input = MockGenericAction(waitUntilCanceled: true)
        let expected = (state: ActionState.finished, completionStatus: ActionCompletionStatus.canceled)

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
        try connect.start()

        let expecation = self.expectation(description: "GenericAction Completion Block Gets Called")

        let proxy = try connect.execute(input) { _ in
            expecation.fulfill()
        }

        ///
        /// Cancel the operation
        ///
        proxy.cancel()

        self.waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            } else {

                XCTAssertEqual(proxy.state,            expected.state)
                XCTAssertEqual(proxy.completionStatus, expected.completionStatus)
            }
        }
    }

    func testCancelGenericActionInUserCode() throws {

        let input = MockGenericAction(waitUntilCanceled: true)
        let expected = (state: ActionState.finished, completionStatus: ActionCompletionStatus.canceled)

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
        try connect.start()

        let expecation = self.expectation(description: "GenericAction Completion Block Gets Called")

        let proxy = try connect.execute(input) { _ in
            expecation.fulfill()
        }

        usleep(100000) /// Sleep for a moment to allow the user code to start

        ///
        /// Cancel the operation
        ///
        proxy.cancel()

        self.waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            } else {

                XCTAssertEqual(proxy.state,            expected.state)
                XCTAssertEqual(proxy.completionStatus, expected.completionStatus)
            }
        }
    }

    func testCancelGenericActionThrowingAnError() throws {

        let input = MockGenericAction(forceError: true)
        let expected = (state: ActionState.finished, completionStatus: ActionCompletionStatus.canceled)

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
        try connect.start()

        let expecation = self.expectation(description: "GenericAction Completion Block Gets Called")

        let proxy = try connect.execute(input) { (proxy) in

            if proxy.error == nil {
                XCTFail("No error thrown.")
            }
            expecation.fulfill()
        }

        usleep(100000) /// Sleep for a moment to allow the user code to start

        ///
        /// Cancel the operation
        ///
        proxy.cancel()

        self.waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            } else {

                XCTAssertEqual(proxy.state,            expected.state)
                XCTAssertEqual(proxy.completionStatus, expected.completionStatus)
            }
        }
    }

    // MARK: EntityAction Execute Tests

    func testExecuteEntityAction() throws {

        let input: [ConnectEntity1] = []
        let expected = (state: ActionState.finished, completionStatus: ActionCompletionStatus.successful)

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
        try connect.start()

        let expecation = self.expectation(description: "EntityAction Completion Block Gets Called")

        let proxy = try connect.execute(MockListAction(testValues: input)) { _ in
            expecation.fulfill()
        }

        self.waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            } else {

                XCTAssertEqual(proxy.state,            expected.state)
                XCTAssertEqual(proxy.completionStatus, expected.completionStatus)
            }
        }
    }

    func testExecuteEntityActionThrowingAnError() throws {

        let input: [ConnectEntity1] = []
        let expected = (state: ActionState.finished, completionStatus: ActionCompletionStatus.failed)

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
        try connect.start()

        let expecation = self.expectation(description: "EntityAction Completion Block Gets Called")

        let proxy = try connect.execute(MockListAction(forceError: true, testValues: input)) { (proxy) in

            if proxy.error == nil {
                XCTFail("No error thrown.")
            }
            expecation.fulfill()
        }

        self.waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            } else {

                XCTAssertEqual(proxy.state,            expected.state)
                XCTAssertEqual(proxy.completionStatus, expected.completionStatus)
            }
        }
    }

    func testExecuteEntityActionUnmanagedEntity() {

        let input = MockListActionUnmanaged()
        let expected = "Entity 'ConnectEntity3Unmanaged' not managed by Connect"

        do {
            let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)

            try connect.start()

            XCTAssertThrowsError( try connect.execute(input) ) { (error) in

                if case Coherence.Errors.unmanagedEntity(let message) = error {
                    XCTAssertEqual(message, expected)
                } else {
                    XCTFail("Wrong error thrown: \(error) is not equal to \(expected)")
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    // MARK: EntityAction Cancel Tests

    func testCancelEntityActionBeforeExecuted() {

        let input: [ConnectEntity1] = []
        let expected = (state: ActionState.finished, completionStatus: ActionCompletionStatus.canceled)

        do {
            let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)

            try connect.start()

            let expecation = self.expectation(description: "EntityAction Completion Block Gets Called")

            let proxy = try connect.execute(MockListAction(waitUntilCanceled: true, testValues: input)) { _ in
                expecation.fulfill()
            }

            ///
            /// Cancel the operation
            ///
            proxy.cancel()

            self.waitForExpectations(timeout: 5) { error in
                if let error = error {
                    XCTFail("waitForExpectationsWithTimeout errored: \(error)")
                } else {

                    XCTAssertEqual(proxy.state,            expected.state)
                    XCTAssertEqual(proxy.completionStatus, expected.completionStatus)
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testCancelEntityActionInUserCode() {

        let input: [ConnectEntity1] = []
        let expected = (state: ActionState.finished, completionStatus: ActionCompletionStatus.canceled)

        do {
            let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)

            try connect.start()

            let expecation = self.expectation(description: "EntityAction Completion Block Gets Called")

            let proxy = try connect.execute(MockListAction(waitUntilCanceled: true, testValues: input)) { _ in
                expecation.fulfill()
            }

            usleep(100000) /// Sleep for a moment to allow the user code to start

            ///
            /// Cancel the operation
            ///
            proxy.cancel()

            self.waitForExpectations(timeout: 5) { error in
                if let error = error {
                    XCTFail("waitForExpectationsWithTimeout errored: \(error)")
                } else {

                    XCTAssertEqual(proxy.state,            expected.state)
                    XCTAssertEqual(proxy.completionStatus, expected.completionStatus)
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testCancelEntityActionThrowingAnError() throws {

        let input: [ConnectEntity1] = []
        let expected = (state: ActionState.finished, completionStatus: ActionCompletionStatus.canceled)

        let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
        try connect.start()

        let expecation = self.expectation(description: "EntityAction Completion Block Gets Called")

        let proxy = try connect.execute(MockListAction(waitUntilCanceled: true, forceError: true, testValues: input)) { (proxy) in

            if proxy.error == nil {
                XCTFail("No error thrown.")
            }
            expecation.fulfill()
        }

        usleep(100000) /// Sleep for a moment to allow the user code to start

        ///
        /// Cancel the operation
        ///
        proxy.cancel()

        self.waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            } else {

                XCTAssertEqual(proxy.state,            expected.state)
                XCTAssertEqual(proxy.completionStatus, expected.completionStatus)
            }
        }
    }
}
