///
///  ActionContextTests.swift
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
///  Created by Tony Stone on 2/9/17.
///
import XCTest
import CoreData

@testable import Coherence

fileprivate let modelName = "ConnectTestModel"

class ActionContextTests: XCTestCase {
    
    private enum Errors: Error {
        case entityNotFound(String)
    }

    override func setUp() {
        super.setUp()

        do {
            try TestPersistentStoreManager.removePersistentStoreCache()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testPerform () {

        do {
            let connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
            try connect.start()

            let actionContext     = connect.newActionContext()
            let validationContext = connect.newBackgroundContext()

            let input    = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))
            let expected = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))

            let expectation = self.expectation(description: "Perform block executed")

            /// 
            /// Test the perform asynchronous method
            ///
            actionContext.perform { () -> Void in

                for object in input.objects {
                    actionContext.insert(object)
                }
                do {
                    try actionContext.save()
                } catch {
                    XCTFail("\(error)")
                    return
                }

                defer {
                    expectation.fulfill()
                }
            }

            ///
            /// Wait for the block to finish and make sure the data was saved correctly
            ///
            self.waitForExpectations(timeout: 5.0, handler: { (error) in

                if let error = error {
                    XCTFail("\(error)")
                } else {
                    validationContext.performAndWait {
                        do {

                            for expectedObject in expected.objects {

                                let fetch = { () -> NSFetchRequest<ConnectEntity1> in

                                    let fetch = NSFetchRequest<ConnectEntity1>()
                                    fetch.entity = expected.entity
                                    fetch.predicate = NSPredicate(format: "id == %ld", expectedObject.id)

                                    return fetch
                                }()

                                let results = try validationContext.fetch(fetch)

                                guard let resultObject = results.last else {
                                    XCTFail()
                                    return
                                }

                                XCTAssertEqual(resultObject.id,                 expectedObject.id)
                                XCTAssertEqual(resultObject.boolAttribute,      expectedObject.boolAttribute)
                                XCTAssertEqual(resultObject.stringAttribute,    expectedObject.stringAttribute)
                                XCTAssertEqual(resultObject.binaryAttribute,    expectedObject.binaryAttribute)
                            }
                        } catch {
                            XCTFail()
                        }
                    }
                }
            })
            
        } catch {
            XCTFail("\(error)")
        }
    }

    func testPerformAndWait () {

        enum Errors: Error {
            case testError(String)
        }

        do {
            let connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
            try connect.start()
            
            let actionContext     = connect.newActionContext()
            let validationContext = connect.newBackgroundContext()

            let input    = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))
            let expected = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))

            actionContext.performAndWait { () -> Void in

                for object in input.objects {
                    actionContext.insert(object)
                }
                do {
                    try actionContext.save()
                } catch {
                    XCTFail("\(error)")
                    return
                }
            }

            validationContext.performAndWait {
                do {

                    for expectedObject in expected.objects {

                        let fetch = { () -> NSFetchRequest<ConnectEntity1> in

                            let fetch = NSFetchRequest<ConnectEntity1>()
                            fetch.entity = expected.entity
                            fetch.predicate = NSPredicate(format: "id == %ld", expectedObject.id)

                            return fetch
                        }()

                        let results = try validationContext.fetch(fetch)

                        guard let resultObject = results.last else {
                            XCTFail()
                            return
                        }

                        XCTAssertEqual(resultObject.id,                 expectedObject.id)
                        XCTAssertEqual(resultObject.boolAttribute,      expectedObject.boolAttribute)
                        XCTAssertEqual(resultObject.stringAttribute,    expectedObject.stringAttribute)
                        XCTAssertEqual(resultObject.binaryAttribute,    expectedObject.binaryAttribute)
                    }
                } catch {
                    XCTFail()
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testPerformAndWaitThrowing() {

        enum Errors: Error {
            case testError(String)
        }

        let input    = "Test Error"
        let expected = input

        do {
            let connect = GenericConnect<ContextStrategy.Mixed>(name: modelName)
            try connect.start()
            
            let actionContext = connect.newActionContext()

            ///
            /// Now execute the merge to delete the objects
            ///
            XCTAssertThrowsError(try actionContext.performAndWait { throw Errors.testError(input)}) { (error) in

                if case Errors.testError(let message) = error {
                    XCTAssertEqual(message, expected)
                } else {
                    XCTFail("Wrong error thrown: \(error) is not equal to \(expected)")
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }
}
