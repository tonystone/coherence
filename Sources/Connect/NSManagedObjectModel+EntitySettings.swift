///
///  NSManagedObjectModel+EntitySettings.swift
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
import CoreData
import TraceLog

extension NSManagedObjectModel {
    
    public var stalenessInterval: Int {
        get {
            return associatedValue(self, key: &stalenessIntervalKey, defaultValue: stalenessIntervalDefault)
        }
        set {
            associatedValue(self, key: &stalenessIntervalKey, value: newValue)
            
            logUpdate(#function, value: newValue)
        }
    }
    
    public var logTransactions: Bool {
        get {
            return associatedValue(self, key: &logTransactionsKey, defaultValue: logTransactionsDefault)
        }
        set {
            associatedValue(self, key: &logTransactionsKey, value: newValue)
            
            logUpdate("logTransactions", value: newValue)
        }
    }
    
    @inline(__always)
    fileprivate
    func logUpdate<T>(_ funcName: String, value: T) {
        logInfo(String(reflecting: type(of: self))) { "Model setting '\(funcName)' changed to '\(value)'" }
    }
}
