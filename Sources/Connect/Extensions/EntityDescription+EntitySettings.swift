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
/// - SeeAlso: `EntitySettings` for more information.
///
extension NSEntityDescription: EntitySettings  {

    ///
    /// - SeeAlso: `EntitySettings` for description.
    ///
    public internal(set) var managed: Bool {
        get {
            return associatedValue(self, key: &managedKey, defaultValue: managedDefault)
        }
        set {
            associatedValue(self, key: &managedKey, value: newValue)
            
            logUpdate(#function, value: newValue)
        }
    }

    ///
    /// - SeeAlso: `EntitySettings` for description.
    ///
    public internal(set) var uniquenessAttributes: [String] {
        get {
            return associatedValue(self, key: &uniquenessAttributesKey, defaultValue: uniquenessAttributesDefault)
        }
        set {
            associatedValue(self, key: &uniquenessAttributesKey, value: newValue)

            logUpdate(#function, value: newValue)
        }
    }

    ///
    /// - SeeAlso: `EntitySettings` for description.
    ///
    public var stalenessInterval: Int {
        get {
            return associatedValue(self, key: &stalenessIntervalKey, defaultValue: stalenessIntervalDefault)
        }
        set {
            associatedValue(self, key: &stalenessIntervalKey, value: newValue)
            
            logUpdate(#function, value: newValue)
        }
    }
    
    ///
    /// - SeeAlso: `EntitySettings` for description.
    ///
    public var logTransactions: Bool {
        get {
            return associatedValue(self, key: &logTransactionsKey, defaultValue: logTransactionsDefault)
        }
        set {
            associatedValue(self, key: &logTransactionsKey, value: newValue)
            
            logUpdate(#function, value: newValue)
        }
    }
    
    @inline(__always)
    private func logUpdate<T>(_ funcName: String, value: T) {
        logInfo(String(reflecting: type(of: self))) { "'\(self.name ?? "Unnamed entity")' setting '\(funcName)' changed to '\(value)'" }
    }
}

internal extension NSEntityDescription {

    internal func setSettings(from dictionary: [AnyHashable: Any]) {

        if let rawValue = dictionary["uniquenessAttributes"] {

            if let value = rawValue as? [String] {
                self.uniquenessAttributes = value
            } else if let value = rawValue as? String {
                self.uniquenessAttributes = value.components(separatedBy: ",").map{ $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            }
        }

        if let rawValue = dictionary["stalenessInterval"] {

            if let value = rawValue as? Int {
                self.stalenessInterval = value
            } else if let string = rawValue as? String,
                      let value  = Int(string) {
                self.stalenessInterval = value
            }
        }

        if let rawValue = dictionary["logTransactions"] {

            if let value = rawValue as? Bool {
                self.logTransactions = value
            } else if let string = rawValue as? String,
                let value  = Bool(string) {
                self.logTransactions = value
            }
        }
    }
}

///
/// Method keys
///
fileprivate var managedKey:              UInt8 = 0
fileprivate var uniquenessAttributesKey: UInt8 = 0
fileprivate var stalenessIntervalKey:    UInt8 = 0
fileprivate var logTransactionsKey:      UInt8 = 0
