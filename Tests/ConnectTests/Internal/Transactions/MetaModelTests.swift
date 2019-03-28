///
///  MetaModelTests.swift
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
import XCTest

@testable import Coherence

class MetaModelTests: XCTestCase {

    func testArchive() {

        let input = MetaModel()
        let expected = input

        let data = NSKeyedArchiver.archivedData(withRootObject: input)
        let result = NSKeyedUnarchiver.unarchiveObject(with: data)

        if let result = result as? MetaModel {

            XCTAssertEqual(result.entityVersionHashesByName.count, expected.entityVersionHashesByName.count)
            XCTAssertEqual(result.entityVersionHashesByName["MetaLogEntry"], expected.entityVersionHashesByName["MetaLogEntry"])
            XCTAssertEqual(result.entityVersionHashesByName["RefreshStatus"], expected.entityVersionHashesByName["RefreshStatus"])
        } else {
            XCTFail("Result is not the correct type of '\(String(describing: MetaModel.self))'.")
        }
    }
}
