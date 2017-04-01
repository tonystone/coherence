///
///  Connect+Errors.swift
///  Pods
///
///  Created by Tony Stone on 2/28/17.
///
///
import Swift

///
/// Errors thrown from `Connect`
///
public enum Errors: Error {
    case unmanagedEntity(String)
    case missingEntityName(String)
}
