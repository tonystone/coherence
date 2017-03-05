///
///  ActionContainer+StatisticsTests.swift
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

@testable import Coherence

///
/// Main test class
///
class ActionContainerStatiticsTests: XCTestCase {

    func testInit() {

        let input = ActionContainer.Statistics()
        let expected: (executionTime: TimeInterval, startTime: Date?, finishTime: Date?) = (0, nil, nil)

        XCTAssertEqual(input.startTime,         expected.startTime)
        XCTAssertEqual(input.finishTime,        expected.finishTime)
        XCTAssertEqual(input.executionTime,     expected.executionTime)
    }

    func testDescription() {

        let input = ActionContainer.Statistics()
        let expected = "{\r" +
                    "\texecutionTime: 0.0000 {\r" +
                    "\t\t startTime: (not started)\r" +
                    "\t\tfinishTime: (not started)\r" +
                    "\t\t}\r" +
                    "\t}"

        XCTAssertEqual(input.description, expected)
    }

    func testDescriptionWithContextStatistics() {

        let input = ActionContainer.Statistics()
        let expected = "{\r" +
            "\texecutionTime: 0.0000 {\r" +
            "\t\t   context: {\r" +
            "\t\t\tblockTime: 0.0000 {\r" +
            "\t\t\t\t saveTime: 0.0000 {\r" +
            "\t\t\t\t\tinserts: 0\r" +
            "\t\t\t\t\tupdates: 0\r" +
            "\t\t\t\t\tdeletes: 0\r" +
            "\t\t\t\t\t}\r" +
            "\t\t\t\tfetchTime: 0.0000 {\r" +
            "\t\t\t\t\tfetches: 0\r" +
            "\t\t\t\t\t}\r" +
            "\t\t\t\totherTime: 0.0000\r" +
            "\t\t\t}\r" +
            "\t\t startTime: (not started)\r" +
            "\t\tfinishTime: (not started)\r" +
            "\t\t}\r" +
        "\t}"

        input.contextStatistics = ActionContext.Statistics()

        XCTAssertEqual(input.description, expected)
    }
}
