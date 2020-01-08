///
///  NSEntityDescription+EntitySettings.swift
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
///  Created by Tony Stone on 8/21/16.
///
import Foundation
import CoreData
import TraceLog

///
/// This extension defines the properties that can be defined
/// for each NSEntityDescription.
///
extension NSEntityDescription {

    ///
    /// Default Entity settings for system
    ///
    public struct Default {
        public static let managed: Bool                  = false
        public static let uniquenessAttributes: [String] = []
    }

    ///
    /// Method keys
    ///
    private struct Key {
        static var managed:              UInt8 = 0
        static var uniquenessAttributes: UInt8 = 0
    }
    
    ///
    /// Is this entity managed by Connect?
    ///
    /// By default, objects are not managed until they pass
    /// the criteria that Connect sets for being able to
    /// manage a specific entity.
    ///
    public internal(set) var managed: Bool {
        get {
            return associatedValue(self, key: &Key.managed, defaultValue: Default.managed)
        }
        set {
            associatedValue(self, key: &Key.managed, value: newValue)
            
            logUpdate(#function, value: newValue)
        }
    }

    ///
    /// Gets the attributes used to define a unique record for this entity type.  This can only be set
    /// statically in the  ManagedObjectModel for this entity.
    ///
    /// The default is an empty array `[]` for this value.
    ///
    public internal(set) var uniquenessAttributes: [String] {
        get {
            return associatedValue(self, key: &Key.uniquenessAttributes, defaultValue: Default.uniquenessAttributes)
        }
        set {
            associatedValue(self, key: &Key.uniquenessAttributes, value: newValue)

            logUpdate(#function, value: newValue)
        }
    }
    
    private func logUpdate<T>(_ funcName: String, value: T) {
        logInfo(Log.tag) {
            return "Entity setting '\(self.name ?? "<Unnamed entity>").\(funcName)' changed to '\(value)'"
        }
    }
}

extension NSEntityDescription {

    internal func setSettings(from dictionary: [AnyHashable: Any]) {

        if let rawValue = dictionary["uniquenessAttributes"] {

            if let value = rawValue as? [String] {
                self.uniquenessAttributes = value
            } else if let value = rawValue as? String {
                self.uniquenessAttributes = value.components(separatedBy: ",").map{ $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            }
        }
    }
}
