///
///  InMemorySequenceTests.swift
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
///  Created by Tony Stone on 4/22/17.
///
import XCTest
@testable import Coherence

class InMemorySequenceTests: XCTestCase {

    func testInit() {

        let _ = InMemorySequence(start: 1)
    }

    func testInitRestartAtLastSequence() throws {

        /// Create the sequence file and start it at 1
        var sequence = InMemorySequence(start: 1)

        for _ in 1...99 {
            let _ = sequence.nextBlock(size: 1)
        }
        /// Create a new sequence starting at the last location
        sequence = InMemorySequence(start: 100)

        /// Test we have a continued sequence
        XCTAssertEqual(sequence.nextBlock(size: 1), 100...100)
    }

    func testNextBlockContinuousSequenceSize1() throws {

        /// Create the sequence file and start it at 1
        let sequence = InMemorySequence(start: 1)

        for index in 1...999 {
            XCTAssertEqual(sequence.nextBlock(size: 1), index...index)
        }
    }

    func testNextBlockContinuousSequenceSize20() throws {

        /// Create the sequence file and start it at 1
        let sequence = InMemorySequence(start: 1)

        var start = 1

        for index in 1...999 {
            XCTAssertEqual(sequence.nextBlock(size: 20), start...index*20)
            start = start + 20
        }
    }

    func testNextBlockConcurrency() throws {

        /// Create the sequence file and start it at 1
        let sequence = InMemorySequence(start: 1)

        let group = DispatchGroup()

        let syncQueue = DispatchQueue(label: "test.sync.queue")
        var groupResults: Set<Int> = []
        var groupDuplicates: [ClosedRange<Int>] = []

        for _ in 0..<20 {
            group.enter()

            DispatchQueue.global(qos: .userInitiated).async {
                var results: [ClosedRange<Int>] = []

                for _ in 0..<1000 {
                    /// Get a block of 1 and store the results for comparison later
                    results.append(sequence.nextBlock(size: 1))
                }

                syncQueue.async {
                    for range in results {
                        let (inserted, _) = groupResults.insert(range.lowerBound)

                        if !inserted {
                            groupDuplicates.append(range)
                        }
                    }
                    group.leave()
                }
            }
        }
        group.wait()

        XCTAssertEqual(groupDuplicates.count, 0, "Duplicate numbers found \(groupDuplicates)")
        XCTAssertEqual(sequence.nextBlock(size: 1), 20001...20001)
    }

    func testNextBlockPerformance() throws {
        let sequence = InMemorySequence(start: 1)
        
        self.measure {
            
            for _ in 1...100000 {
                let _ = sequence.nextBlock(size: 10)
            }
        }
    }
}
