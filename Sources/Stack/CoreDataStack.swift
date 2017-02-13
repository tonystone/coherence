///
///  CoreDataStack.swift
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
///  Created by Tony Stone on 1/28/17.
///
import Foundation
import CoreData

public protocol CoreDataStack {

    associatedtype BackgroundContextType: NSManagedObjectContext

    ///
    /// The main context.
    ///
    /// This context should be used for read operations only.  Use it for all fetches and NSFechtedResultsControllers.
    ///
    /// It will be maintained automatically and be kept consistent.
    ///
    /// - Warning: You should only use this context on the main thread.  If you must work on a background thread, use the method `edittContext` while on the thread.  See that method for more details
    ///
    var viewContext: NSManagedObjectContext { get }

    ///
    /// Gets a new NSManagedObjectContext that can be used for updating objects.
    ///
    /// At save time, resource manager will merge those changes back to the mainManagedObjectContext.
    ///
    /// - Note: This method and the returned NSManagedObjectContext can be used on a background thread as long as you get the context while on that thread.  It can also be used on the main thread if gotten while on the main thread.
    ///
    func newBackgroundContext() -> BackgroundContextType
}
