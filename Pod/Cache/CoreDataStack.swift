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
    
    private typealias CoreDataStackType = GenericCoreDataStack<NSPersistentStoreCoordinator, NSManagedObjectContext>
    
    private let impl: CoreDataStackType!   // Note: this is protected with a guard in the designated init method
    
    /**
        Initializes the receiver with a managed object model.
    
        - Parameter managedObjectModel: A managed object model.
    */
    public init?(managedObjectModel model: NSManagedObjectModel) {
        impl = CoreDataStackType(managedObjectModel: model, logTag: String(CoreDataStack.self))
    }
    
    /**
        Initializes the receiver with a managed object model.
     
        - Parameter managedObjectModel: A managed object model.
        - configurationOptions: Optional configuration settings by persistent store config name (see ConfigurationOptionsType for structure)
     */
    public init?(managedObjectModel model: NSManagedObjectModel, configurationOptions options: ConfigurationOptionsType) {
        impl = CoreDataStackType(managedObjectModel: model, configurationOptions: options, logTag: String(CoreDataStack.self))
    }
    
    public func mainThreadContext () -> NSManagedObjectContext {
        return impl.mainThreadContext()
    }
    
    public func editContext () -> NSManagedObjectContext {
        return impl.editContext()
    }
}


