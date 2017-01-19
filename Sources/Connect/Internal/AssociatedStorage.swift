//
//  AssociatedStorage.swift
//  Pods
//
//  Created by Tony Stone on 8/22/16.
//
//

import Foundation
import TraceLog

internal func associatedValue<T: AnyObject>(_ object: AnyObject, key: UnsafePointer<UInt8>, defaultValue: @autoclosure () -> T) -> T {
    
    //If there is already a value, return it
    if let value = objc_getAssociatedObject(object, key) as? T {
        return value
    }
    return defaultValue()
}

internal func associatedValue<T: AnyObject>(_ object: AnyObject, key: UnsafePointer<UInt8>, value: T) {
    objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN)
}
