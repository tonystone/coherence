///
///  PartialFunctions.swift
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
///  Created by Tony Stone on 3/5/17.
///
import Swift
import CoreData
import TraceLog

///
/// Abort the program if block throws an exception otherwise return the value..
///
internal func abortIfError<T>(file: StaticString = #file, line: UInt = #line, block: () throws -> T) -> T {
    do {
        return try block()
    } catch {
        fatalError("\(error)", file: file, line: line)
    }
}

///
/// Abort the program if block returns nil an otherwise return the result value as a non-optional.
///
internal func abortIfNil<T>(message: String, file: StaticString = #file, line: UInt = #line, block: () -> T?) -> T {

    guard let value = block() else {
        fatalError(message, file: file, line: line)
    }
    return value
}

///
/// Abort the program if block returns nil an otherwise return the result value as a non-optional.
///
@discardableResult
internal func abortIfFalse(message: String, file: StaticString = #file, line: UInt = #line, condition: @autoclosure () -> Bool) {

    guard !condition() else {
        fatalError(message, file: file, line: line)
    }
}
