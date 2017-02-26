///
///  GenericCoreDataStackTests.swift
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
///  Created by Tony Stone on 10/31/16.
///
import XCTest
import CoreData
import Coherence

fileprivate let firstName = "First"
fileprivate let lastName  = "Last"
fileprivate let userName  = "First Last"

class GenericCoreDataStackTests: XCTestCase {

    fileprivate typealias CoreDataStackType = GenericCoreDataStack<NSPersistentStoreCoordinator, NSManagedObjectContext>

    override func setUp() {
        super.setUp()
        
        do {
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

        let model = TestModel1()
        let name  = String(describing: type(of: TestModel1.self))

        let stack = CoreDataStackType(name: name, managedObjectModel: model)
        
        do {
            let _ = try stack.loadPersistentStores()
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: name, storeType: defaultStoreType))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testConstruction_WithOptions() {
        
        let model = TestModel1()
        let name  = String(describing: type(of: model.self))

        let stack = CoreDataStackType(name: name, managedObjectModel: model)

        var options: [AnyHashable: Any] = defaultStoreOptions
        
        options[overwriteIncompatibleStoreOption] = true
        
        do {
            let _ = try stack.loadPersistentStores(configurationOptions: [defaultModelConfigurationName: (storeType: NSSQLiteStoreType, storeOptions: options, migrationManager: nil)])
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: name, storeType: defaultStoreType))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testConstruction_WithEmptyOptions() {
        
        let model = TestModel1()
        let name  = String(describing: type(of: model.self))

        let stack = CoreDataStackType(name: name, managedObjectModel: model)

        do {
            let _ = try stack.loadPersistentStores(configurationOptions: [:])
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: name, storeType: defaultStoreType))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testConstruction_MultiConfiguration_SQLiteStoreType() throws {
        
        let model = TestModel3()
        let name  = String(describing: type(of: model.self))

        let stack = CoreDataStackType(name: name, managedObjectModel: model)

        var options: [AnyHashable: Any] = defaultStoreOptions
        options[overwriteIncompatibleStoreOption] = true
        
        do {
            /// TestModel2 has multiple configurations and should will produce multiple persistent stores.
            let _ = try stack.loadPersistentStores(configurationOptions: ["PersistentEntities": (storeType: NSSQLiteStoreType, storeOptions: options, migrationManager: nil),
                                                                          "TransientEntities":  (storeType: NSSQLiteStoreType, storeOptions: options, migrationManager: nil)])
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: name, storeType: NSSQLiteStoreType, configuration: "PersistentEntities"))
            XCTAssertTrue(try persistentStoreExists(storePrefix: name, storeType: NSSQLiteStoreType, configuration: "TransientEntities"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testConstruction_MultiConfiguration_InMemoryType() throws {
        
        let model = TestModel3()
        let name  = String(describing: type(of: model.self))

        let stack = CoreDataStackType(name: name, managedObjectModel: model)
        
        var options: [AnyHashable: Any] = defaultStoreOptions
        options[overwriteIncompatibleStoreOption] = true
        
        do {
            /// TestModel2 has multiple configurations and should will produce multiple persistent stores.
            let _ = try stack.loadPersistentStores(configurationOptions: ["PersistentEntities": (storeType: NSInMemoryStoreType, storeOptions: options, migrationManager: nil),
                                                                          "TransientEntities":  (storeType: NSInMemoryStoreType, storeOptions: options, migrationManager: nil)])
            
            XCTAssertFalse(try persistentStoreExists(storePrefix: name, storeType: NSInMemoryStoreType, configuration: "PersistentEntities"))
            XCTAssertFalse(try persistentStoreExists(storePrefix: name, storeType: NSInMemoryStoreType, configuration: "TransientEntities"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testConstruction_MultiConfiguration_MixedType() throws {
        
        let model = TestModel3()
        let name  = String(describing: type(of: model.self))

        let stack = CoreDataStackType(name: name, managedObjectModel: model)
        
        var options: [AnyHashable: Any] = defaultStoreOptions
        options[overwriteIncompatibleStoreOption] = true
        
        do {
            /// TestModel2 has multiple configurations and should will produce multiple persistent stores.
            let _ = try stack.loadPersistentStores(configurationOptions: ["PersistentEntities": (storeType: NSSQLiteStoreType,   storeOptions: options, migrationManager: nil),
                                                                          "TransientEntities":  (storeType: NSInMemoryStoreType, storeOptions: options, migrationManager: nil)])

            XCTAssertTrue(try persistentStoreExists (storePrefix: name, storeType: NSSQLiteStoreType,   configuration: "PersistentEntities"))
            XCTAssertFalse(try persistentStoreExists(storePrefix: name, storeType: NSInMemoryStoreType, configuration: "TransientEntities"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testConstruction_MultiConfiguration_DefaultStoreType() throws {
        
        let model = TestModel3()
        let name  = String(describing: type(of: model.self))

        let stack = CoreDataStackType(name: name, managedObjectModel: model)

        do {
            /// TestModel2 has multiple configurations and should will produce multiple persistent stores.
            let _ = try stack.loadPersistentStores()
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: name, storeType: defaultStoreType, configuration: "PersistentEntities"))
            XCTAssertTrue(try persistentStoreExists(storePrefix: name, storeType: defaultStoreType, configuration: "TransientEntities"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testStackCreation_OverrideStoreIfModelIncompatible() throws {
        
        let model     = TestModel1()
        let name      = String(describing: type(of: model.self))
        let storeType = NSSQLiteStoreType

        var stack = CoreDataStackType(name: name, managedObjectModel: TestModel2())

        // Initialize model 2 (no configurations), with model 1s name
        try stack.loadPersistentStores()
        
        let storeDate = try persistentStoreDate(storePrefix: name, storeType: storeType, configuration: nil)
        
        sleep(1)
        
        var options: [AnyHashable: Any] = defaultStoreOptions
        options[overwriteIncompatibleStoreOption] = true

        // Now use model 1 with model 1s name
        stack = CoreDataStackType(name: name, managedObjectModel: model)
        try stack.loadPersistentStores(configurationOptions: [defaultModelConfigurationName: (storeType: storeType, storeOptions: options, migrationManager: nil)])

        XCTAssertTrue(try persistentStoreDate(storePrefix: name, storeType: storeType, configuration: nil) > storeDate)
    }
    
    func testConstruction_WithAsyncErrorHandler() {
        
        let model = TestModel1()
        let name  = String(describing: type(of: model.self))

        let stack = CoreDataStackType(name: name, managedObjectModel: model, asyncErrorBlock: { (error) -> Void in
            // Async Error block
            print(error.localizedDescription)
        })

        do {
            let _ = try stack.loadPersistentStores()
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: name, storeType: defaultStoreType))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testCRUD () throws {
        
        let model = TestModel1()
        let name  = String(describing: type(of: model.self))
        
        let coreDataStack = CoreDataStackType(name: name, managedObjectModel: model)
        try coreDataStack.loadPersistentStores()
        
        let editContext = coreDataStack.newBackgroundContext()
        let viewContext = coreDataStack.viewContext
        
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
        
        viewContext.performAndWait {
            if let userId = userId {
                savedUser = viewContext.object(with: userId)
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

}
