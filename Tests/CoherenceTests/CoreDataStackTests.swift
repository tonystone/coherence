///
///  CoreDataStackTests.swift
///
///  Copyright 2016 The Climate Corporation
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
///  Created by Tony Stone on 1/15/16.
///
import XCTest
import CoreData
import Coherence

let firstName = "First"
let lastName  = "Last"
let userName  = "First Last"

class CoreDataStackTests: XCTestCase {

    fileprivate var coreDataStack: CoreDataStack!
    
    override  func setUp() {
        super.setUp()
        
        do {
            coreDataStack = try CoreDataStack(managedObjectModel: TestModel1(), storeNamePrefix: String(describing: TestModel1.self))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    override  func tearDown() {
        coreDataStack = nil
        
        super.tearDown()
    }

    func testConstruction () {
    
        XCTAssertNotNil(coreDataStack)
    }
    
    func testStackCreation_OverrideStoreIfModelIncompatible() throws {
        
        coreDataStack = nil
        
        let model = TestModel2()
        
        var options: [AnyHashable: Any] = defaultStoreOptions
        options[CCOverwriteIncompatibleStoreOption] = true

        coreDataStack = try CoreDataStack(managedObjectModel: model, storeNamePrefix: String(describing: TestModel1.self), configurationOptions: [defaultModelConfigurationName: (storeType: NSSQLiteStoreType, storeOptions: options, migrationManager: nil)])
        
        XCTAssertNotNil(coreDataStack)
        
        // clean up
        coreDataStack = nil
        
        let cachesURL = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let storeURL = cachesURL.appendingPathComponent("TestModel.sqlite")
        
        try deleteIfExists(fileURL: storeURL)
        try deleteIfExists(fileURL: URL(fileURLWithPath: "\(storeURL.path)-shm"))
        try deleteIfExists(fileURL: URL(fileURLWithPath: "\(storeURL.path)-wal"))
    }
    
    func testCRUD () {
        
        let editContext       = coreDataStack.editContext()
        let mainThreadContext = coreDataStack.mainThreadContext()
        
        var userId: NSManagedObjectID? = nil
        
        editContext.performAndWait {
            
            if let insertedUser = NSEntityDescription.insertNewObject(forEntityName: "User", into:editContext) as? User {
                
                insertedUser.firstName = firstName
                insertedUser.lastName  = lastName
                insertedUser.userName  = userName
                
                do {
                    try editContext.save()
                } catch {
                    XCTFail()
                }
                userId = insertedUser.objectID
            }
        }
        
        var savedUser: NSManagedObject? = nil
        
        mainThreadContext.performAndWait {
            if let userId = userId {
                savedUser = mainThreadContext.object(with: userId)
            }
        }
        
        XCTAssertNotNil(savedUser)
        
        if let savedUser = savedUser as? User {
            
            XCTAssertTrue(savedUser.firstName == firstName)
            XCTAssertTrue(savedUser.lastName  == lastName)
            XCTAssertTrue(savedUser.userName  == userName)
            
        } else {
            XCTFail()
        }

    }

    fileprivate func deleteIfExists(fileURL url: URL) throws {
    
        let fileManager = FileManager.default
        let path = url.path

        if fileManager.fileExists(atPath: path) {
            try fileManager.removeItem(at: url)
        }
    }
}
