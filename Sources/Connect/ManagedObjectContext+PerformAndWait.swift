
///
///  ManagedObjectContext+PerformAndWait.swift
///
///  Copyright 2015 Tony Stone
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
///  Created by Tony Stone on 1/29/17.
///
import CoreData

///
/// Extensions for use in Actions and other places tha use ManagedObjectContexts
///
public extension NSManagedObjectContext {

    ///
    /// synchronously performs the block on the context's queue with a throwing block.  May safely be called reentrantly and throw Errors from this block.
    ///
    public func performAndWait(_ block: @escaping () throws -> Void) throws {
        var error: Error? = nil

        self.performAndWait {
            do {
                try block()
            } catch let blockError {
                error = blockError
            }
        }
        if let error = error {
            throw error
        }
    }
}

