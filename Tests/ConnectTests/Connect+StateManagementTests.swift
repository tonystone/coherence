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

class ConnectStateManagementTests: XCTestCase {

    override func setUp() {
        super.setUp()

        do {
            try removePersistentStoreCache()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testQueueStateAfterInitIsSuspended() {

        let input = (modelName: "ConnectTestModel")
        let expected = true

        let connect = Connect(name: input)

        XCTAssertEqual(connect.suspended, expected)
    }

    func testQueueStateAfterStartIsNotSuspended() throws {

        let input = (modelName: "ConnectTestModel")
        let expected = false

        let connect = Connect(name: input)
        try connect.start()

        XCTAssertEqual(connect.suspended, expected)
    }

    func testSuspendedAfterStartUp() throws {

        let input = (modelName: "ConnectTestModel", isSuspended: true)
        let expected = input.isSuspended

        let connect = Connect(name: input.modelName)
        try connect.start()
        connect.suspended = input.isSuspended

        XCTAssertEqual(connect.suspended, expected)
    }
}
