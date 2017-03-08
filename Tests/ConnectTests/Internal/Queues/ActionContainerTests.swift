///
///  ActionContainerTests.swift
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
///  Created by Tony Stone on 3/7/17.
///
import XCTest

@testable import Coherence

private class MockAction: Action {
    func cancel() {}
}

///
/// Main test class
///
class ActionContainerTests: XCTestCase {
    
    func testExecute() {

        let input = ActionContainer(action: MockAction(), notificationService: NotificationService(), completionBlock: nil)

        ///
        /// Note: Since ActionContainer is a base class, this method 
        ///       never gets called unless you allocate the base and 
        ///       execute it directly.  This call is the execute the 
        ///       method (which does nothing) to increase the code
        ///       coverage.
        ///
        XCTAssertNotNil(try input.execute())
    }
    
}
