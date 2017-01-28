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

extension NSEntityDescription  {

    /**
        Is this entity managed by Connect?
     */
    public internal(set) var managed: Bool {
        get {
            return associatedValue(self, key: &managedKey, defaultValue: managedDefault)
        }
        set {
            associatedValue(self, key: &managedKey, value: newValue)
            
            logUpdate(#function, value: newValue)
        }
    }

    /**
     */
    public internal(set) var uniquenessAttributes: [String]? {
        get {
            return associatedValue(self, key: &uniquenessAttributesKey, defaultValue: uniquenessAttributesDefault)
        }
        set {
            associatedValue(self, key: &uniquenessAttributesKey, value: newValue)

            logUpdate(#function, value: newValue)
        }
    }

    /**
        Sets the amount of time before the resource is updated again from the master source
     
        Note: if this value is not set at this level, the model value will be used.
     */
    public var stalenessInterval: Int {
        get {
            return associatedValue(self, key: &stalenessIntervalKey, defaultValue: self.managedObjectModel.stalenessInterval)
        }
        set {
            associatedValue(self, key: &stalenessIntervalKey, value: newValue)
            
            logUpdate(#function, value: newValue)
        }
    }
    
    /**
        Should Connect log transactions for this entity?
     
        Note: if this value is not set at this level, the model value will be used.
    */
    public var logTransactions: Bool {
        get {
            return associatedValue(self, key: &logTransactionsKey, defaultValue: self.managedObjectModel.logTransactions)
        }
        set {
            associatedValue(self, key: &logTransactionsKey, value: newValue)
            
            logUpdate(#function, value: newValue)
        }
    }
    
    @inline(__always)
    fileprivate
    func logUpdate<T>(_ funcName: String, value: T) {
        logInfo(String(reflecting: type(of: self))) { "'\(self.name ?? String(reflecting: self))' setting '\(funcName)' changed to '\(value)'" }
    }
    @inline(__always)
    fileprivate
    func logUpdate<T>(_ funcName: String, value: T?) {
        var newValue: Any = "nil"

        if let value = value {
            newValue = value
        }
        logInfo(String(reflecting: type(of: self))) { "'\(self.name ?? String(reflecting: self))' setting '\(funcName)' changed to '\(newValue)'" }
    }
}

internal extension NSEntityDescription {

    internal func setSetttings(from dictionary: [AnyHashable: Any]) {

        if let stringValue = dictionary["stalenessInterval"] as? String,
           let value = Int(stringValue) {

            self.stalenessInterval = value
        }

        if let stringValue = dictionary["logTransactions"] as? String,
            let value = Bool(stringValue) {

            self.logTransactions = value
        }
    }
}





