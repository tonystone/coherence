///
///  ContextStrategy+IndependentDirect.swift
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
import TraceLog
import CoreData

extension ContextStrategy {

    ///
    /// A strategy that manages independent contexts (for view and background) connected directly to the `NSPersistentStoreCoordinator`.
    ///
    /// ```
    ///    backgroundContext -\
    ///                        \
    ///                          -> PersistentStoreCoordinator
    ///                        /
    ///    viewContext -------/
    ///
    /// ```    /// - Note: The view context will not be kept up to date with this strategy.
    ///
    public class IndependentDirect: ContextStrategy, ContextStrategyType {

        public required init(persistentStoreCoordinator: NSPersistentStoreCoordinator, errorHandler: @escaping AsyncErrorHandlerBlock) {

            /// Now the main thread context
            self.viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            self.viewContext.persistentStoreCoordinator = persistentStoreCoordinator

            super.init(persistentStoreCoordinator: persistentStoreCoordinator, errorHandler: errorHandler)
        }

        public let viewContext: NSManagedObjectContext

        public func newBackgroundContext<T: NSManagedObjectContext>() -> T {

            let context = T(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
            context.persistentStoreCoordinator = self.persistentStoreCoordinator

            return context
        }
    }
}
