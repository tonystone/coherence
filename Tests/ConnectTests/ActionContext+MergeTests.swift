///
///  ActionContext+MergeTests.swift
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
///  Created by Tony Stone on 2/8/17.
///
import XCTest
import CoreData
@testable import Coherence

class ActionContextMergeTests: XCTestCase {

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

    func testMergeInsert() {

        do {
            let connect = Connect(name: modelName, managedObjectModel: self.testModel)
            try connect.start()

            let actionContext = connect.newActionContext()
            let viewContext   = connect.viewContext

            let input    = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))
            let expected = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))

            ///
            /// Execute the merge to test the insert capabilities
            ///
            try actionContext.performAndWait {
                try actionContext.merge(objects: input.objects, for: input.entity)
            }

            viewContext.performAndWait {
                do {

                    for expectedObject in expected.objects {

                        let fetch = { () -> NSFetchRequest<ConnectEntity1> in

                            let fetch = NSFetchRequest<ConnectEntity1>()
                            fetch.entity = expected.entity
                            fetch.predicate = NSPredicate(format: "id == %ld", expectedObject.id)

                            return fetch
                        }()

                        let results = try viewContext.fetch(fetch)
                        
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

    func testMergeUpdate() {

        do {
            let connect = Connect(name: modelName, managedObjectModel: self.testModel)
            try connect.start()

            let actionContext = connect.newActionContext()
            let viewContext   = connect.viewContext

            let input    = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Update", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))
            let expected = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Update", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))

            ///
            /// Prime the database with objects
            ///
            try actionContext.performAndWait {
                let (_, objects) = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))
                for object in  objects {
                    actionContext.insert(object)
                }
                try actionContext.save()
            }

            ///
            /// Now execute the merge with updated objects
            ///
            try actionContext.performAndWait {
                try actionContext.merge(objects: input.objects, for: input.entity)
            }

            ///
            /// Now test that the view contains the updated objects.
            ///
            viewContext.performAndWait {
                do {

                    for expectedObject in expected.objects {

                        let fetch = { () -> NSFetchRequest<ConnectEntity1> in

                            let fetch = NSFetchRequest<ConnectEntity1>()
                            fetch.entity = expected.entity
                            fetch.predicate = NSPredicate(format: "id == %ld", expectedObject.id)

                            return fetch
                        }()

                        let results = try viewContext.fetch(fetch)

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

    func testMergeDelete() {

        do {
            let connect = Connect(name: modelName, managedObjectModel: self.testModel)
            try connect.start()

            let actionContext = connect.newActionContext()
            let viewContext   = connect.viewContext

            let input    = try ConnectEntity1.newTestObjects(for: actionContext, count: 0, boolValue: true, stringValue: "Delete", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))
            let expected = try ConnectEntity1.newTestObjects(for: actionContext, count: 0, boolValue: true, stringValue: "Delete", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))

            ///
            /// Prime the database with objects
            ///
            try actionContext.performAndWait {
                let (_, objects) = try ConnectEntity1.newTestObjects(for: actionContext, count: 10, boolValue: true, stringValue: "Insert", dataValue: Data(bytes: [UInt8(2), UInt8(2), UInt8(2)]))

                for object in  objects {
                    actionContext.insert(object)
                }
                try actionContext.save()
            }

            ///
            /// Now execute the merge to delete the objects
            ///
            try actionContext.performAndWait {
                try actionContext.merge(objects: input.objects, for: input.entity)
            }

            ///
            /// Now test that the view does NOT contains the deleted objects.
            ///
            viewContext.performAndWait {
                do {
                
                    let fetch = { () -> NSFetchRequest<ConnectEntity1> in

                        let fetch = NSFetchRequest<ConnectEntity1>()
                        fetch.entity = expected.entity

                        return fetch
                    }()

                    let results = try viewContext.fetch(fetch)

                    XCTAssertEqual(results.count, expected.objects.count)
                } catch {
                    XCTFail()
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }
}
