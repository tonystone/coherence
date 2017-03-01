///
///  Connect+Errors.swift
///  Pods
///
///  Created by Tony Stone on 2/28/17.
///
///
import Swift

///
/// Error messages and other routines for handling errors from `Connect`.
///
public extension Connect {

    ///
    /// Errors thrown from `Connect`
    ///
    public enum Errors: Error {
        case unmanagedEntity(String)
    }
}
