//
//  ReadOnlyContextTests.swift
//  Coherence
//
//  Created by Tony Stone on 2/12/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import XCTest
import CoreData
@testable import Coherence

fileprivate let firstName = "First"
fileprivate let lastName  = "Last"
fileprivate let userName  = "First Last"

class ReadOnlyContextTests: XCTestCase {

    fileprivate typealias CoreDataStackType = GenericCoreDataStack<NSPersistentStoreCoordinator, NSManagedObjectContext>

    func testSaveThrowing () {

        do {
            let expected = "Cannot save, context is read only."

            let model  = TestModel1()
            let prefix = String(describing: type(of: model.self))

            let coreDataStack = try CoreDataStackType(managedObjectModel: model, storeNamePrefix: prefix)

            let viewContext = coreDataStack.viewContext

            ///
            /// Now execute the merge to delete the objects
            ///
            XCTAssertThrowsError(try viewContext.performAndWait { try viewContext.save() }) { (error) in

                if case ReadOnlyContextErrors.readOnlyContext (let message) = error {
                    XCTAssertEqual(message, expected)
                } else {
                    XCTFail("Wrong error thrown: \(error) is not equal to \(expected)")
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testSaveOverrideFalse () {

        do {
            let expected = "Cannot save, context is read only."

            let model  = TestModel1()
            let prefix = String(describing: type(of: model.self))

            let coreDataStack = try CoreDataStackType(managedObjectModel: model, storeNamePrefix: prefix)

            guard let viewContext = coreDataStack.viewContext as? ReadOnlyContext else {
                XCTFail("Returned Context is not a ReadOnlyContext.")
                return
            }

            ///
            /// Now execute the merge to delete the objects
            ///
            XCTAssertThrowsError(try viewContext.performAndWait { try viewContext.save(override: false) }) { (error) in

                if case ReadOnlyContextErrors.readOnlyContext (let message) = error {
                    XCTAssertEqual(message, expected)
                } else {
                    XCTFail("Wrong error thrown: \(error) is not equal to \(expected)")
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testSaveOverrideTrue () {

        do {
            let input = (firstName: "First", lastName: "Last", userName: "First Last")
            let expected = input

            let model  = TestModel1()
            let prefix = String(describing: type(of: model.self))

            let coreDataStack = try CoreDataStackType(managedObjectModel: model, storeNamePrefix: prefix)

            guard let viewContext = coreDataStack.viewContext as? ReadOnlyContext else {
                XCTFail("Returned Context is not a ReadOnlyContext.")
                return
            }

            guard let parentContext = viewContext.parent else {
                XCTFail("ViewContext had no parent.")
                return
            }
            var userId: NSManagedObjectID? = nil

            viewContext.performAndWait {

                if let insertedUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: viewContext) as? User {

                    insertedUser.firstName = input.firstName
                    insertedUser.lastName  = input.lastName
                    insertedUser.userName  = input.userName

                    do {
                        try viewContext.save(override: true)
                    } catch {
                        XCTFail()
                    }
                    userId = insertedUser.objectID
                }
            }

            var savedUser: NSManagedObject? = nil

            parentContext.performAndWait {
                if let userId = userId {
                    savedUser = parentContext.object(with: userId)
                }
            }

            XCTAssertNotNil(savedUser)

            if let savedUser = savedUser as? User {
                
                XCTAssertEqual(savedUser.firstName, expected.firstName)
                XCTAssertEqual(savedUser.lastName,  expected.lastName)
                XCTAssertEqual(savedUser.userName,  expected.userName)
                
            } else {
                XCTFail()
            }
        } catch {
            XCTFail("\(error)")
        }
    }
}
