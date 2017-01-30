///
///  ConnectTests.swift
///
///  Copyright 2016 Tony Stone
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
///  Created by Tony Stone on 1/22/17.
///
import XCTest
import CoreData
import Coherence

class ConnectTests: XCTestCase {

    var testModel: NSManagedObjectModel! = nil
    let modelName = "ConnectTestModel"

    override func setUp() {
        super.setUp()

        let bundle    = Bundle(for: type(of: self))

        guard let url = bundle.url(forResource: modelName, withExtension: "momd") else {
            fatalError("Could not locate \(modelName).momd in bundle.")
        }

        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model at \(url).")
        }

        self.testModel = model

        do {
            try removePersistentStoreCache()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testConstruction() {

        let input = self.testModel!
        let expected = input

        XCTAssertEqual(try Connect(name: modelName, managedObjectModel: input).managedObjectModel , expected)
    }

    func testExecuteGenericAction()  {

        let input = MockGenericAction()
        let expected = (state: ActionState.finished, completionStatus: ActionCompletionStatus.successful)

        do {
            let connect = try Connect(name: modelName, managedObjectModel: self.testModel)

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

    func testExecuteEntityAction() {
    
        let input = MockListAction()
        let expected = (state: ActionState.finished, completionStatus: ActionCompletionStatus.successful)

        do {
            let connect = try Connect(name: modelName, managedObjectModel: self.testModel)

            let expecation = self.expectation(description: "EntityAction Completion Block Gets Called")

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
}
