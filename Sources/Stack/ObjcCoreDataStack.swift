///
///  CoreDataStack.swift
///
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
///  Created by Tony Stone on 12/14/15.
///
import Foundation
import CoreData
import TraceLog

@objc public final class ObjcCoreDataStack: NSObject, CoreDataStack  {
    
    fileprivate typealias CoreDataStackType = GenericCoreDataStack<NSPersistentStoreCoordinator, NSManagedObjectContext, NSManagedObjectContext>
    
    fileprivate let impl: CoreDataStackType
    
    /**
        Initializes the receiver with a managed object model.
     
        - parameters:
          - managedObjectModel: A managed object model.
          - storeNamePrefix: A unique name prefix for the persistent store to be created.
          - configurationOptions: Optional configuration settings by persistent store config name (see ConfigurationOptionsType for structure)
     */
    public init(name: String, managedObjectModel model: NSManagedObjectModel) {
        impl = CoreDataStackType(name: name, managedObjectModel: model, logTag: String(describing: ObjcCoreDataStack.self))
    }

    public func loadPersistentStores() throws {
        try impl.loadPersistentStores()
    }

    public func loadPersistentStores(configurationOptions options: ConfigurationOptionsType) throws {
        try impl.loadPersistentStores(configurationOptions: options)
    }

    public var viewContext: NSManagedObjectContext {
        return impl.viewContext
    }
    
    public func newBackgroundContext() -> NSManagedObjectContext {
        return impl.newBackgroundContext()
    }
}
