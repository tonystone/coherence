///
///  NSManagedObjectContext+Extensions.swift
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
///  Created by Tony Stone on 2/6/17.
///
import CoreData

extension NSManagedObjectContext {

    ///
    /// synchronously performs the block on the context's queue with a throwing block.  May safely be called reentrantly and throw Errors from this block.
    ///
    @nonobjc
    public func performAndWait(_ block: @escaping () throws -> Void) throws {
        var error: Error? = nil

        self.performAndWait { () -> Void in
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

    ///
    /// Asynchronously performs the block on the context's queue with a throwing block calling errorHandler if an error is thrown. May safely be called reentrantly and throw Errors from this block.
    ///
    @nonobjc
    public func perform(onError: @escaping (Error) -> Void, _ block: @escaping () throws -> Void) {
        self.performAndWait { () -> Void in
            do {
                try block()

            } catch {
                onError(error)
            }
        }

    }
}
