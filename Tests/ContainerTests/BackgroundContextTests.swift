//
//  BackgroundContextTests.swift
//  Coherence
//
//  Created by Tony Stone on 4/2/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//
import Foundation
import XCTest

import CoreData
@testable import Coherence

class BackgroundContextTests: XCTestCase {
    
    func testInitWithConcurrencyType() {
        let input = NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType

        XCTAssertNotNil(BackgroundContext(concurrencyType: input))
    }

    func testInitWithCoder() {
        let input = BackgroundContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)

        let archive = NSKeyedArchiver.archivedData(withRootObject: input)
        let result  = NSKeyedUnarchiver.unarchiveObject(with: archive)

        XCTAssertTrue(result is BackgroundContext)
    }

    func testDeinitBlock() {
        var input: BackgroundContext? = BackgroundContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)

        let expectation = self.expectation(description: "Deinit called")

        input?.deinitBlock = { [weak expectation] in
            expectation?.fulfill()
        }

        /// Release the variable so deinit gets called.
        input = nil

        self.waitForExpectations(timeout: 5)
    }

    func testDeinitBlockNil() {
        ///
        /// This simply forces the deinit to be executed with a nil deinitBlock to exercise that code path.
        ///
        let _ = BackgroundContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)

        sleep(1)
    }
}
