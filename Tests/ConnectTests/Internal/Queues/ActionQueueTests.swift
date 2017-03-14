///
///  ActionQueueTests.swift
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
///  Created by Tony Stone on 3/5/17.
///
import XCTest
import TraceLog

@testable import Coherence

private class MockOperation: Operation {

    private let waitUntilCanceled: Bool

    private var waitSemaphore: DispatchSemaphore
    private let waitTimeout: Double

    init(waitUntilCanceled: Bool = false, timeout: Double = 5) {
        self.waitUntilCanceled = waitUntilCanceled
        self.waitSemaphore     = DispatchSemaphore(value: 0)
        self.waitTimeout       = timeout
    }

    internal override func main() {

        if self.waitUntilCanceled {
            if self.waitSemaphore.wait(timeout: .now() + self.waitTimeout) == .success {
                logInfo { "Canceled." }
            }
        }
    }
    public override func cancel() {
        self.waitSemaphore.signal()
    }
}

///
/// Main test class
///
class ActionQueueTests: XCTestCase {

    func testInitWithDefaultConcurrencyMode() {

        let input = ActionQueue(label: "test.queue.1", qos: .utility)
        let expected = ConcurrencyMode.serial

        XCTAssertEqual(input.concurrencyMode, expected)
    }

    func testInitSerialQueue() {

        let input = ActionQueue(label: "test.queue.2", qos: .utility, concurrencyMode: .serial)
        let expected = ConcurrencyMode.serial

        XCTAssertEqual(input.concurrencyMode, expected)
    }

    func testInitConcurrentQueue() {

        let input = ActionQueue(label: "test.queue.3", qos: .utility, concurrencyMode: .concurrent)
        let expected = ConcurrencyMode.concurrent

        XCTAssertEqual(input.concurrencyMode, expected)
    }

    func testDescription() throws {

        let input = ActionQueue(label: "test.queue.4", qos: .utility)
        let expected = "ActionQueue (name: test.queue.4, qos: DispatchQoS(qosClass: Dispatch.DispatchQoS.QoSClass.utility, relativePriority: 0), concurrencyMode: serial)"

        XCTAssertEqual(input.description, expected)
    }

    func testIsSuspendedTrue() {

        let input = true
        let expected = true

        let queue = ActionQueue(label: "test.queue.5", qos: .utility)
        queue.suspended = input

        XCTAssertEqual(queue.suspended, expected)
    }

    func testIsSuspendedFalse() {

        let input = false
        let expected = false

        let queue = ActionQueue(label: "test.queue.6", qos: .utility)
        queue.suspended = input

        XCTAssertEqual(queue.suspended, expected)
    }

    func testExecuteOperation() {

        let expectation = self.expectation(description: "Action Executed.")

        let input = BlockOperation(block: { expectation.fulfill() } )

        let queue = ActionQueue(label: "test.queue.7", qos: .utility)
        queue.addAction(input)

        self.waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            } 
        }
    }

    func testCancelAllActions() throws {

        let input    = MockOperation(waitUntilCanceled: true)
        let expected = self.expectation(description: "Action Executed.")

        input.completionBlock = {
            expected.fulfill()
        }

        let queue = ActionQueue(label: "test.queue.8", qos: .utility)
        queue.addAction(input)

        ///
        /// Cancel the operation
        ///
        queue.cancelAllActions()

        self.waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testWaitForAllActionsToComplete() throws {

        let input    = MockOperation(waitUntilCanceled: true)
        let expected = self.expectation(description: "Action Executed.")

        input.completionBlock = {
            expected.fulfill()
        }

        let queue = ActionQueue(label: "test.queue.9", qos: .utility)
        queue.addAction(input)

        ///
        /// Cancel the operation
        ///
        queue.cancelAllActions()

        queue.waitUntilAllActionsAreFinished()

        self.waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
