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
internal func abortIfError<T>(block: () throws -> T) -> T {
    do {
        return try block()
    } catch {
        fatalError("\(error.localizedDescription)")
    }
}

///
/// Abort the program if block returns nil an otherwise return the result value as a non-optional.
///
internal func abortIfNil<T>(message: String, block: () -> T?) -> T {

    guard let value = block() else {
        fatalError(message)
    }
    return value
}
