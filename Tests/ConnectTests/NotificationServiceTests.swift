//
//  NotificationServiceTests.swift
//  Coherence
//
//  Created by Tony Stone on 2/26/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import XCTest
@testable import Coherence

///
/// Test Action implementaion.
///
fileprivate class TestAction: Action {

    func cancel() {}
}

///
/// Test ActionStatistics implementation.
///
fileprivate class TestActionStatistics: ActionStatistics {

    var startTime: Date? = nil

    var finishTime: Date? = nil

    var executionTime: TimeInterval = 0.0
}

///
/// Test ActionProxy implementation.
///
fileprivate class TestActionProxy: ActionProxy {

    fileprivate let name: String

    var action: Action = TestAction()

    var state: ActionState

    var completionStatus: ActionCompletionStatus = .unknown

    var error: Error? = nil

    var statistics: ActionStatistics = TestActionStatistics()

    func cancel() {}

    init(name: String, actionState: ActionState) {
        self.name  = name
        self.state = actionState
    }
}

///
/// Main tests
///
class NotificationServiceTests: XCTestCase {

    let notificationService = NotificationService()

    override func setUp() {
        self.notificationService.source = self

        super.setUp()
    }

    func testActionProxyDidStartExecuting() {

        let input    = TestActionProxy(name: "TestProxy", actionState: ActionState.executing)
        let expected = input

        let _ = self.expectation(forNotification: Connect.Notification.ActionDidStartExecuting.rawValue, object: self) { (notification) -> Bool in

            XCTAssertNotNil(notification.userInfo?[Connect.Notification.Key.ActionProxy])
            XCTAssert(notification.userInfo?[Connect.Notification.Key.ActionProxy] is TestActionProxy)

            if let actionProxy = notification.userInfo?[Connect.Notification.Key.ActionProxy] as? TestActionProxy {

                XCTAssertEqual(actionProxy.name,  expected.name)
                XCTAssertEqual(actionProxy.state, expected.state)
            }
            return true
        }

        ///
        /// Send the notification through the NotificationService
        ///
        notificationService.actionProxy(input, didChangeState: input.state)

        ///
        /// Wait for it to be posted.
        ///
        self.waitForExpectations(timeout: 1)
    }

    func testActionProxyDidFinishExecuting() {

        let input    = TestActionProxy(name: "TestProxy", actionState: ActionState.finished)
        let expected = input

        let _ = self.expectation(forNotification: Connect.Notification.ActionDidFinishExecuting.rawValue, object: self) { (notification) -> Bool in

            XCTAssertNotNil(notification.userInfo?[Connect.Notification.Key.ActionProxy])
            XCTAssert(notification.userInfo?[Connect.Notification.Key.ActionProxy] is TestActionProxy)

            if let actionProxy = notification.userInfo?[Connect.Notification.Key.ActionProxy] as? TestActionProxy {

                XCTAssertEqual(actionProxy.name,  expected.name)
                XCTAssertEqual(actionProxy.state, expected.state)
            }
            return true
        }

        ///
        /// Send the notification through the NotificationService
        ///
        notificationService.actionProxy(input, didChangeState: input.state)

        ///
        /// Wait for it to be posted.
        ///
        self.waitForExpectations(timeout: 1)
    }

    func testActionProxyDidFinishExecutingWithIncorrectState() {


        let input = TestActionProxy(name: "TestProxy", actionState: ActionState.pending)

        ///
        /// Send the notification through the NotificationService
        ///
        /// Note: this should be a no-op but there does not seem to be a way to test
        ///       for a notification not going out.  We have this test here to complete
        ///       the code coverage.
        notificationService.actionProxy(input, didChangeState: input.state)
    }
}
