///
///  MetaLogEntryTypeTests.swift
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
///  Created by Tony Stone on 3/6/17.
///
import Foundation
import XCTest

@testable import Coherence

class MetaLogEntryTypeTests: XCTestCase {

    func testBeginMarkerDescription() {

        let input = MetaLogEntryType.beginMarker
        let expected = "beginMarker"

        XCTAssertEqual(input.description, expected)
    }

    func testEndMarkerDescription() {

        let input = MetaLogEntryType.endMarker
        let expected = "endMarker"

        XCTAssertEqual(input.description, expected)
    }

    func testInsertDescription() {

        let input = MetaLogEntryType.insert
        let expected = "insert"

        XCTAssertEqual(input.description, expected)
    }

    func testUpdateDescription() {

        let input = MetaLogEntryType.update
        let expected = "update"

        XCTAssertEqual(input.description, expected)
    }

    func testdeleteDescription() {

        let input = MetaLogEntryType.delete
        let expected = "delete"

        XCTAssertEqual(input.description, expected)
    }
}

