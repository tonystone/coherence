///
///  ContextStrategy.swift
///
///  Copyright 2017 Tony Stone
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
///  Created by Tony Stone on 3/29/17.
///
import Swift
import CoreData

///
/// A type that defines an interface for a ManagedObejctContext strategy.  This defines the hiearchy of 
/// the contexts and determines how they are kept up to date when changes are made in contexts.
///
public protocol ContextStrategyType {

    init(persistentStoreCoordinator: NSPersistentStoreCoordinator, errorHandler: @escaping AsyncErrorHandlerBlock)

    var viewContext: NSManagedObjectContext { get }

    func newBackgroundContext<T: NSManagedObjectContext>() -> T
}

///
/// Base class to implement `ContextStrategyType` classes.
///
public class ContextStrategy {

    internal let errorHandler: AsyncErrorHandlerBlock
    internal let persistentStoreCoordinator: NSPersistentStoreCoordinator

    public required init(persistentStoreCoordinator: NSPersistentStoreCoordinator, errorHandler: @escaping AsyncErrorHandlerBlock) {

        self.persistentStoreCoordinator = persistentStoreCoordinator
        self.errorHandler = errorHandler
    }
}
