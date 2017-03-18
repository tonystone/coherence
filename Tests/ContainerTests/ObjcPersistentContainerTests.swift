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

fileprivate let firstName = "First"
fileprivate let lastName  = "Last"
fileprivate let userName  = "First Last"

class ObjcPersistentContainerTests: XCTestCase {
    
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
        let expected = (name: input, model: ModelLoader.load(name: "ContainerTestModel4"))

        let container = ObjcPersistentContainer(name: input)

        XCTAssertEqual(container.name,               expected.name)
        XCTAssertEqual(container.managedObjectModel, expected.model)
    }

    func testConstructionNameAndModel() {

        let input  = (name: "TestModel", model: ModelLoader.load(name: "ContainerTestModel4"))
        let expected = input

        let container = ObjcPersistentContainer(name: input.name, managedObjectModel: input.model)

        XCTAssertEqual(container.name,               expected.name)
        XCTAssertEqual(container.managedObjectModel, expected.model)
    }
    
    func testConstruction_WithOptions () {
        
        let input = (name: "ContainerTestModel1", model: ModelLoader.load(name: "ContainerTestModel1"))

        var options: [AnyHashable: Any] = defaultStoreOptions
        
        options[overwriteIncompatibleStoreOption] = true
        
        do {
            let _ = try ObjcPersistentContainer(name: input.name, managedObjectModel: input.model).loadPersistentStores(configurationOptions: [defaultModelConfigurationName: (storeType: NSSQLiteStoreType, storeOptions: options)])
            
            XCTAssertTrue(try persistentStoreExists(storePrefix: input.name, storeType: defaultStoreType))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testCRUD () throws {

        let input = (name: "ContainerTestModel1", model: ModelLoader.load(name: "ContainerTestModel1"))

        let coreDataStack = ObjcPersistentContainer(name: input.name, managedObjectModel: input.model)
        try coreDataStack.loadPersistentStores()
        
        let editContext = coreDataStack.newBackgroundContext()
        let mainContext = coreDataStack.viewContext
        
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
        
        mainContext.performAndWait {
            if let userId = userId {
                savedUser = mainContext.object(with: userId)
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

    fileprivate func deleteIfExists(fileURL url: URL) throws {
    
        let fileManager = FileManager.default
        let path = url.path

        if fileManager.fileExists(atPath: path) {
            try fileManager.removeItem(at: url)
        }
    }
}
