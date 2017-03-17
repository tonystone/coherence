///
///  PartialFunctions.swift
///  Pods
///
///  Created by Tony Stone on 3/5/17.
///
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
