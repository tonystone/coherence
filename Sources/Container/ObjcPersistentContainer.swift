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

///
/// An Objective-C wrapper around a GenericPersistentContainer (for objective-c use only).
///
@objc(ObjcPersistentContainer)
public final class ObjcPersistentContainer: NSObject {
    
    fileprivate typealias ContainerType = GenericPersistentContainer<ContextStrategy.Mixed>
    
    fileprivate let impl: ContainerType

    ///
    /// Initializes a Container with the given name.
    ///
    /// - Note: By default, the provided `name` value is used to name the persistent store and is used to look up the name of the `NSManagedObjectModel` object to be used with the `GenericPersistentContainer` object.
    ///
    /// - Parameters:
    ///     - name: The name of the model file in the bundle. The model will be located based on the name given.
    ///
    /// - Returns: A core data stack initialized with the given name.
    ///
    public init(name: String) {
        impl = ContainerType(name: name, logTag: String(describing: ObjcPersistentContainer.self))
    }

    ///
    /// Initializes the receiver with the given name and a managed object model.
    ///
    /// - Note: By default, the provided `name` value is used as the name of the persistent store associated with the container. Passing in the `NSManagedObjectModel` object overrides the lookup of the model by the provided name value.
    ///
    /// - Parameters:
    ///     - name: The name of the model file in the bundle.
    ///     - managedObjectModel: A managed object model.
    ///
    /// - Returns: A ObjcPersistentContainer initialized with the given name and model.
    ///
    public init(name: String, managedObjectModel model: NSManagedObjectModel) {
        impl = ContainerType(name: name, managedObjectModel: model, logTag: String(describing: ObjcPersistentContainer.self))
    }

    public func loadPersistentStores() throws {
        try impl.attachPersistentStores()
    }

    public func loadPersistentStores(for storeConfigurations: [StoreConfiguration]) throws {
        try impl.attachPersistentStores(for: storeConfigurations)
    }

    public var name: String {
        return impl.name
    }

    public var managedObjectModel: NSManagedObjectModel {
        return impl.managedObjectModel
    }

    public var viewContext: NSManagedObjectContext {
        return impl.viewContext
    }
    
    public func newBackgroundContext() -> NSManagedObjectContext {
        return impl.newBackgroundContext()
    }
}
