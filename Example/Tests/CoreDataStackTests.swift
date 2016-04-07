//
//  CacheTests.swift
//  Coherence
//
//  Created by Tony Stone on 1/5/16.
//  Copyright © 2016 Tony Stone. All rights reserved.
//

import XCTest
import CoreData
import Coherence

let firstName = "First"
let lastName  = "Last"
let userName  = "First Last"

class CoreDataStackTests: XCTestCase {

    private var coreDataStack: CoreDataStack!
    
    override  func setUp() {
        super.setUp()
        
        let bundle = NSBundle(forClass: CoreDataStackTests.self)
        
        if let dataModelURL = bundle.URLForResource("TestModel", withExtension: "momd") {
            
            let model = NSManagedObjectModel(contentsOfURL: dataModelURL)
            coreDataStack = CoreDataStack(managedObjectModel: model!, storeNamePrefix: "TestModel")
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
        
        let model = SimpleEntityModel()
        
        var options: [NSObject:AnyObject] = defaultStoreOptions
        options[CCOverwriteIncompatibleStoreOption] = true

        coreDataStack = CoreDataStack(managedObjectModel: model, storeNamePrefix: "TestModel", configurationOptions: [defaultModelConfigurationName: (storeType: NSSQLiteStoreType, storeOptions: options, migrationManager: nil)])
        
        XCTAssertNotNil(coreDataStack)
        
        // clean up
        coreDataStack = nil
        
        let cachesURL = try NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let storeURL = cachesURL.URLByAppendingPathComponent("TestModel.sqlite")
        
        try deleteIfExists(fileURL: storeURL)
        try deleteIfExists(fileURL: NSURL(fileURLWithPath: "\(storeURL.path!)-shm"))
        try deleteIfExists(fileURL: NSURL(fileURLWithPath: "\(storeURL.path!)-wal"))
    }
    
    func testCRUD () {
        
        let editContext       = coreDataStack.editContext()
        let mainThreadContext = coreDataStack.mainThreadContext()
        
        var userId: NSManagedObjectID? = nil
        
        editContext.performBlockAndWait {
            
            if let insertedUser = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext:editContext) as? User {
                
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
        
        mainThreadContext.performBlockAndWait {
            if let userId = userId {
                savedUser = mainThreadContext.objectWithID(userId)
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

    private func deleteIfExists(fileURL url: NSURL) throws {
    
        let fileManager = NSFileManager.defaultManager()
        
        if let path = url.path {
            if fileManager.fileExistsAtPath(path) {
                try fileManager.removeItemAtURL(url)
            }
        }
    }
}