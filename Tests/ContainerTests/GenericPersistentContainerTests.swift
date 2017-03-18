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

@testable import Coherence

fileprivate let firstName = "First"
fileprivate let lastName  = "Last"
fileprivate let userName  = "First Last"

class GenericPersistentContainerTests: XCTestCase {

    fileprivate typealias PersistentContainerType = GenericPersistentContainer<NSPersistentStoreCoordinator, NSManagedObjectContext, NSManagedObjectContext>

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

    func testConstructionWithName() {

        let input  = "ContainerTestModel4"
        let expected = (name: input, model: ModelLoader.load(name: input))

        let container = PersistentContainerType(name: input)

        XCTAssertEqual(container.name,               expected.name)
        XCTAssertEqual(container.managedObjectModel, expected.model)
    }

    func testConstructionNameAndModel() {

        let input  = (name: "ContainerTestModel", model: ModelLoader.load(name: "ContainerTestModel4"))
        let expected = input

        let container = PersistentContainerType(name: input.name, managedObjectModel: input.model)

        XCTAssertEqual(container.name,               expected.name)
        XCTAssertEqual(container.managedObjectModel, expected.model)
    }

    func testConstructionWithOptions() {
        
        let model = ModelLoader.load(name: "ContainerTestModel1")
        let name  = "ContainerTestModel1"

        let container = PersistentContainerType(name: name, managedObjectModel: model)

        var options: [AnyHashable: Any] = defaultStoreOptions
        
        options[overwriteIncompatibleStoreOption] = true
        
        do {
            let _ = try container.loadPersistentStores(configurationOptions: [defaultModelConfigurationName: (storeType: NSSQLiteStoreType, storeOptions: options)])
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: name, storeType: defaultStoreType))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testConstructionWithEmptyOptions() {
        
        let model = ModelLoader.load(name: "ContainerTestModel1")
        let name  = String(describing: type(of: model.self))

        let container = PersistentContainerType(name: name, managedObjectModel: model)

        do {
            let _ = try container.loadPersistentStores(configurationOptions: [:])
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: name, storeType: defaultStoreType))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testConstructionWithMultiConfigurationAndSQLiteStoreType() throws {
        
        let model = ModelLoader.load(name: "ContainerTestModel3")
        let name  = "ContainerTestModel3"

        let container = PersistentContainerType(name: name, managedObjectModel: model)

        var options: [AnyHashable: Any] = defaultStoreOptions
        options[overwriteIncompatibleStoreOption] = true
        
        do {
            /// TestModel2 has multiple configurations and should will produce multiple persistent stores.
            let _ = try container.loadPersistentStores(configurationOptions: ["PersistentEntities": (storeType: NSSQLiteStoreType, storeOptions: options),
                                                                          "TransientEntities":  (storeType: NSSQLiteStoreType, storeOptions: options)])
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: name, storeType: NSSQLiteStoreType, configuration: "PersistentEntities"))
            XCTAssertTrue(try persistentStoreExists(storePrefix: name, storeType: NSSQLiteStoreType, configuration: "TransientEntities"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testConstructionWithMultiConfigurationAndInMemoryType() throws {
        
        let model = ModelLoader.load(name: "ContainerTestModel3")
        let name  = "ContainerTestModel3"

        let container = PersistentContainerType(name: name, managedObjectModel: model)
        
        var options: [AnyHashable: Any] = defaultStoreOptions
        options[overwriteIncompatibleStoreOption] = true
        
        do {
            /// TestModel2 has multiple configurations and should will produce multiple persistent stores.
            let _ = try container.loadPersistentStores(configurationOptions: ["PersistentEntities": (storeType: NSInMemoryStoreType, storeOptions: options),
                                                                          "TransientEntities":  (storeType: NSInMemoryStoreType, storeOptions: options)])
            
            XCTAssertFalse(try persistentStoreExists(storePrefix: name, storeType: NSInMemoryStoreType, configuration: "PersistentEntities"))
            XCTAssertFalse(try persistentStoreExists(storePrefix: name, storeType: NSInMemoryStoreType, configuration: "TransientEntities"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testConstructionWithMultiConfigurationAndMixedType() throws {
        
        let model = ModelLoader.load(name: "ContainerTestModel3")
        let name  = "ContainerTestModel3"

        let container = PersistentContainerType(name: name, managedObjectModel: model)
        
        var options: [AnyHashable: Any] = defaultStoreOptions
        options[overwriteIncompatibleStoreOption] = true
        
        do {
            /// TestModel2 has multiple configurations and should will produce multiple persistent stores.
            let _ = try container.loadPersistentStores(configurationOptions: ["PersistentEntities": (storeType: NSSQLiteStoreType,   storeOptions: options),
                                                                          "TransientEntities":  (storeType: NSInMemoryStoreType, storeOptions: options)])

            XCTAssertTrue(try persistentStoreExists (storePrefix: name, storeType: NSSQLiteStoreType,   configuration: "PersistentEntities"))
            XCTAssertFalse(try persistentStoreExists(storePrefix: name, storeType: NSInMemoryStoreType, configuration: "TransientEntities"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testConstructionWithMultiConfigurationAndDefaultStoreType() throws {
        
        let model = ModelLoader.load(name: "ContainerTestModel3")
        let name  = "ContainerTestModel3"

        let container = PersistentContainerType(name: name, managedObjectModel: model)

        do {
            /// TestModel2 has multiple configurations and should will produce multiple persistent stores.
            let _ = try container.loadPersistentStores()
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: name, storeType: defaultStoreType, configuration: "PersistentEntities"))
            XCTAssertTrue(try persistentStoreExists(storePrefix: name, storeType: defaultStoreType, configuration: "TransientEntities"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testStackCreationWithOverrideStoreIfModelIncompatible() throws {
        
        let model     = ModelLoader.load(name: "ContainerTestModel1")
        let name      = "ContainerTestModel1"
        let storeType = NSSQLiteStoreType

        var container = PersistentContainerType(name: name, managedObjectModel: ModelLoader.load(name: "ContainerTestModel2"))

        // Initialize model 2 (no configurations), with model 1s name
        try container.loadPersistentStores()
        
        let storeDate = try persistentStoreDate(storePrefix: name, storeType: storeType, configuration: nil)
        
        sleep(1)
        
        var options: [AnyHashable: Any] = defaultStoreOptions
        options[overwriteIncompatibleStoreOption] = true

        // Now use model 1 with model 1s name
        container = PersistentContainerType(name: name, managedObjectModel: model)
        try container.loadPersistentStores(configurationOptions: [defaultModelConfigurationName: (storeType: storeType, storeOptions: options)])

        XCTAssertTrue(try persistentStoreDate(storePrefix: name, storeType: storeType, configuration: nil) > storeDate)
    }
    
    func testConstructionWithAsyncErrorHandler() {
        
        let model     = ModelLoader.load(name: "ContainerTestModel1")
        let name      = "ContainerTestModel1"

        let container = PersistentContainerType(name: name, managedObjectModel: model, asyncErrorBlock: { (error) -> Void in
            // Async Error block
            print(error.localizedDescription)
        })

        do {
            let _ = try container.loadPersistentStores()
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: name, storeType: defaultStoreType))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testDefaultErrorHandlingBlock() {

        enum TestErrors: Error {
            case testError
        }

        let input = TestErrors.testError

        ///
        /// Note: there is really no way at the moment to validate the output of the default handler so this is just to exercise it for test coverage completion.
        ///
        Coherence.defaultAsyncErrorHandlingBlock(input)
    }

    func testCRUD () throws {
        
        let model     = ModelLoader.load(name: "ContainerTestModel1")
        let name      = "ContainerTestModel1"
        
        let coreDataStack = PersistentContainerType(name: name, managedObjectModel: model)
        try coreDataStack.loadPersistentStores()
        
        let editContext = coreDataStack.newBackgroundContext()
        let viewContext = coreDataStack.viewContext
        
        var userId: NSManagedObjectID? = nil
        
        editContext.performAndWait {
            
            if let insertedUser = NSEntityDescription.insertNewObject(forEntityName: "ContainerUser", into:editContext) as? ContainerUser {
                
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
        
        if let savedUser = savedUser as? ContainerUser {
            
            XCTAssertTrue(savedUser.firstName == firstName)
            XCTAssertTrue(savedUser.lastName  == lastName)
            XCTAssertTrue(savedUser.userName  == userName)
            
        } else {
            XCTFail()
        }
    }
}
