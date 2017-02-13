///
///  ManagedObjectContext+ExtensionsTests.swift
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
///  Created by Tony Stone on 2/11/17.
///
import XCTest
import CoreData

@testable import Coherence

class ManagedObjectContextExtensionsTests: XCTestCase {

    private enum Errors: Error {
        case entityNotFound(String)
    }

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

    func testPerformAndWaitThrowing() {

        enum Errors: Error {
            case testError(String)
        }

        let input    = "Test Error"
        let expected = input

        do {
            let connect       = try Connect(name: modelName, managedObjectModel: self.testModel)
            let actionContext = connect.newBackgroundContext()

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

