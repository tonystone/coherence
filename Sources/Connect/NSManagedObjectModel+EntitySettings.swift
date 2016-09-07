//
//  NSManagedObjectModel+EntitySettings.swift
//  Pods
//
//  Created by Tony Stone on 8/22/16.
//
//
import CoreData
import TraceLog

extension NSManagedObjectModel {
    
    public var stalenessInterval: Int {
        get {
            return associatedValue(self, key: &stalenessIntervalKey, defaultValue: stalenessIntervalDefault as NSNumber) as Int
        }
        set {
            associatedValue(self, key: &stalenessIntervalKey, value: NSNumber(value: newValue))
            
            logUpdate(#function, value: newValue)
        }
    }
    
    public var logTransactions: Bool {
        get {
            return associatedValue(self, key: &logTransactionsKey, defaultValue: logTransactionsDefault as NSNumber) as Bool
        }
        set {
            associatedValue(self, key: &logTransactionsKey, value: NSNumber(value: newValue))
            
            logUpdate("logTransactions", value: newValue)
        }
    }
    
    @inline(__always)
    fileprivate
    func logUpdate<T>(_ funcName: String, value: T) {
        logTrace(String(reflecting: type(of: self)), level: 2) { "Model: \"\(funcName)\" value changed to \"\(value)\"" }
    }
}
