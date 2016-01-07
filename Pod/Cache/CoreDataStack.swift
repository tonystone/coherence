//
//  CoreDataStack.swift
//  Pods
//
//  Created by Tony Stone on 12/14/15.
//
//

import Foundation
import CoreData
import TraceLog

@objc public final class CoreDataStack : NSObject  {
    
    private typealias CoreDataStackType = GenericCoreDataStack<CoreDataStack,NSPersistentStoreCoordinator, NSManagedObjectContext>
    
    private let impl: CoreDataStackType!   // Note: this is protected with a guard in the designated init method
    
    /**
        Initializes the receiver with a managed object model.
    
        - Parameter managedObjectModel: A managed object model.
    
        - Returns: The receiver, initialized with model.
    */
    public init?(managedObjectModel model: NSManagedObjectModel) {
        impl = CoreDataStackType(managedObjectModel: model)
    }
    
    /**
        Initializes the receiver with a managed object model.
     
        - Parameter managedObjectModel: A managed object model.
     
        - Returns: The receiver, initialized with model.
     */
    public init?(managedObjectModel model: NSManagedObjectModel, configurationOptions: ConfigurationOptionsType) {
        impl = CoreDataStackType(managedObjectModel: model, configurationOptions: configurationOptions)
    }
    
    public func mainThreadContext () -> NSManagedObjectContext {
        return impl.mainThreadContext()
    }
    
    public func editContext () -> NSManagedObjectContext {
        return impl.editContext()
    }
}


