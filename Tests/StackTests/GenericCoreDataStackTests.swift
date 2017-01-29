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
        
        let model  = TestModel1()
        let prefix = String(describing: type(of: model.self))
        
        do {
            let _ = try CoreDataStackType(managedObjectModel: model, storeNamePrefix: prefix)
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: prefix, storeType: defaultStoreType))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testConstruction_WithOptions() {
        
        let model  = TestModel1()
        let prefix = String(describing: type(of: model.self))
        
        var options: [AnyHashable: Any] = defaultStoreOptions
        
        options[overwriteIncompatibleStoreOption] = true
        
        do {
            let _ = try CoreDataStackType(managedObjectModel: model, storeNamePrefix: prefix, configurationOptions: [defaultModelConfigurationName: (storeType: NSSQLiteStoreType, storeOptions: options, migrationManager: nil)])
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: prefix, storeType: defaultStoreType))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testConstruction_WithEmptyOptions() {
        
        let model  = TestModel1()
        let prefix = String(describing: type(of: model.self))
        
        do {
            let _ = try CoreDataStackType(managedObjectModel: model, storeNamePrefix: prefix, configurationOptions: [:])
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: prefix, storeType: defaultStoreType))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testConstruction_MultiConfiguration_SQLiteStoreType() throws {
        
        let model  = TestModel3()
        let prefix = String(describing: type(of: model.self))
        
        var options: [AnyHashable: Any] = defaultStoreOptions
        options[overwriteIncompatibleStoreOption] = true
        
        do {
            /// TestModel2 has multiple configurations and should will produce multiple persistent stores.
            let _ = try CoreDataStackType(managedObjectModel: model,
                                          storeNamePrefix: prefix,
                                          configurationOptions: ["PersistentEntities": (storeType: NSSQLiteStoreType, storeOptions: options, migrationManager: nil),
                                                                 "TransientEntities":  (storeType: NSSQLiteStoreType, storeOptions: options, migrationManager: nil)])
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: prefix, storeType: NSSQLiteStoreType, configuration: "PersistentEntities"))
            XCTAssertTrue(try persistentStoreExists(storePrefix: prefix, storeType: NSSQLiteStoreType, configuration: "TransientEntities"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testConstruction_MultiConfiguration_InMemoryType() throws {
        
        let model  = TestModel3()
        let prefix = String(describing: type(of: model.self))
        
        var options: [AnyHashable: Any] = defaultStoreOptions
        options[overwriteIncompatibleStoreOption] = true
        
        do {
            /// TestModel2 has multiple configurations and should will produce multiple persistent stores.
            let _ = try CoreDataStackType(managedObjectModel: model,
                                          storeNamePrefix: prefix,
                                          configurationOptions: ["PersistentEntities": (storeType: NSInMemoryStoreType, storeOptions: options, migrationManager: nil),
                                                                 "TransientEntities":  (storeType: NSInMemoryStoreType, storeOptions: options, migrationManager: nil)])
            
            XCTAssertFalse(try persistentStoreExists(storePrefix: prefix, storeType: NSInMemoryStoreType, configuration: "PersistentEntities"))
            XCTAssertFalse(try persistentStoreExists(storePrefix: prefix, storeType: NSInMemoryStoreType, configuration: "TransientEntities"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testConstruction_MultiConfiguration_MixedType() throws {
        
        let model  = TestModel3()
        let prefix = String(describing: type(of: model.self))
        
        var options: [AnyHashable: Any] = defaultStoreOptions
        options[overwriteIncompatibleStoreOption] = true
        
        do {
            /// TestModel2 has multiple configurations and should will produce multiple persistent stores.
            let _ = try CoreDataStackType(managedObjectModel: model,
                                          storeNamePrefix: prefix,
                                          configurationOptions: ["PersistentEntities": (storeType: NSSQLiteStoreType,   storeOptions: options, migrationManager: nil),
                                                                 "TransientEntities":  (storeType: NSInMemoryStoreType, storeOptions: options, migrationManager: nil)])
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: prefix,  storeType: NSSQLiteStoreType,   configuration: "PersistentEntities"))
            XCTAssertFalse(try persistentStoreExists(storePrefix: prefix, storeType: NSInMemoryStoreType, configuration: "TransientEntities"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testConstruction_MultiConfiguration_DefaultStoreType() throws {
        
        let model  = TestModel3()
        let prefix = String(describing: type(of: model.self))

        do {
            /// TestModel2 has multiple configurations and should will produce multiple persistent stores.
            let _ = try CoreDataStackType(managedObjectModel: model, storeNamePrefix: prefix)
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: prefix, storeType: defaultStoreType, configuration: "PersistentEntities"))
            XCTAssertTrue(try persistentStoreExists(storePrefix: prefix, storeType: defaultStoreType, configuration: "TransientEntities"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testStackCreation_OverrideStoreIfModelIncompatible() throws {
        
        let model       = TestModel1()
        let prefix      = String(describing: type(of: model.self))
        let storeType   = NSSQLiteStoreType
        
        // Initialize model 2 (no configurations), with model 1s name
        let _ = try CoreDataStackType(managedObjectModel: TestModel2(), storeNamePrefix: prefix)
        
        let storeDate = try persistentStoreDate(storePrefix: prefix, storeType: storeType, configuration: nil)
        
        sleep(2)
        
        var options: [AnyHashable: Any] = defaultStoreOptions
        options[overwriteIncompatibleStoreOption] = true

        // Now use model 1 with model 1s name
        let _ = try CoreDataStackType(managedObjectModel: model, storeNamePrefix: prefix, configurationOptions: [defaultModelConfigurationName: (storeType: storeType, storeOptions: options, migrationManager: nil)])
        
        XCTAssertTrue(try persistentStoreDate(storePrefix: prefix, storeType: storeType, configuration: nil) > storeDate)
    }
    
    func testConstruction_WithAsyncErrorHandler() {
        
        let model  = TestModel1()
        let prefix = String(describing: type(of: model.self))
        
        do {
            let _ = try CoreDataStackType(managedObjectModel: model, storeNamePrefix: prefix, asyncErrorBlock: { (error) -> Void in
                // Async Error block
                print(error.localizedDescription)
            })
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: prefix, storeType: defaultStoreType))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testCRUD () throws {
        
        let model  = TestModel1()
        let prefix = String(describing: type(of: model.self))
        
        let coreDataStack = try CoreDataStackType(managedObjectModel: model, storeNamePrefix: prefix)
        
        let editContext = coreDataStack.editContext
        let mainContext = coreDataStack.mainContext
        
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
        
        mainContext.performAndWait {
            if let userId = userId {
                savedUser = mainContext.object(with: userId)
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
