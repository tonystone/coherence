//
//  PersistentStoreCoordinatorTests.swift
//  Coherence
//
//  Created by Tony Stone on 1/22/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import XCTest
import CoreData
import Coherence

class PersistentStoreCoordinatorTests: XCTestCase {

    var testModel:     NSManagedObjectModel! = nil
    var testDirectory: URL! = nil

    override func setUp() {
        super.setUp()

        let modelName = "HR"
        let bundle    = Bundle(for: type(of: self))

        guard let url = bundle.url(forResource: modelName, withExtension: "momd") else {
            fatalError("Could not locate \(modelName).momd in bundle.")
        }

        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model at \(url).")
        }

        self.testModel = model

        do {
            self.testDirectory = try cachesDirectory()

            try removePersistentStoreCache()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    override func tearDown() {
        do {
            try removePersistentStoreCache()
        } catch {
            XCTFail(error.localizedDescription)
        }
        super.tearDown()
    }

    func testConstruction() {

        let input = self.testModel!
        let expected = input

        XCTAssertEqual(PersistentStoreCoordinator(managedObjectModel: input).managedObjectModel , expected)
    }

    func testConstructionNoWriteAheadLog() {

        let input = self.testModel!
        let expected = input

        XCTAssertEqual(PersistentStoreCoordinator(managedObjectModel: input, enableLogging: false).managedObjectModel , expected)
    }

    func testExecuteGenericAction() throws {

        let input = MockGenericAction()
        let expected = (state: ActionState.finished, completionStatus: ActionCompletionStatus.successful)

        let expecation = self.expectation(description: "Completion Block Gets Called")

        let proxy = try PersistentStoreCoordinator(managedObjectModel: self.testModel).execute(input) { _ in
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
    }

    func testExecuteEntityAction() throws {

        let input = MockListAction()
        let expected = (state: ActionState.finished, completionStatus: ActionCompletionStatus.successful)

        let expecation = self.expectation(description: "Completion Block Gets Called")

        let proxy = try PersistentStoreCoordinator(managedObjectModel: self.testModel).execute(input) { _ in
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
    }
}
