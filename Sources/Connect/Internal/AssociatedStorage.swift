///
///  AssociatedStorage.swift
///
///  Copyright 2016 Tony Stone
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
///  Created by Tony Stone on 8/22/16.
///
import Foundation
import TraceLog

internal func associatedValue<T: Any>(_ object: Any, key: UnsafePointer<UInt8>, defaultValue: T) -> T {
    
    //If there is already a value, return it
    if let value = objc_getAssociatedObject(object, key) as? T {
        return value
    }
    return defaultValue
}

internal func associatedValue<T: Any>(_ object: Any, key: UnsafePointer<UInt8>, value: T) {
    objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN)
}

internal func associatedValue<T: Any>(_ object: Any, key: UnsafePointer<UInt8>, defaultValue: T?) -> T? {

    //If there is already a value, return it
    if let value = objc_getAssociatedObject(object, key) as? T {
        return value
    }
    return defaultValue
}

internal func associatedValue<T: Any>(_ object: Any, key: UnsafePointer<UInt8>, value: T?) {
    if let value = value {
        objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN)
    } else {
        objc_setAssociatedObject(object, key, nil, .OBJC_ASSOCIATION_RETAIN)
    }
}
