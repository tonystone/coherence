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
            associatedValue(self, key: &stalenessIntervalKey, value: NSNumber(integer: newValue))
            
            logUpdate(__FUNCTION__, value: newValue)
        }
    }
    
    public var logTransactions: Bool {
        get {
            return associatedValue(self, key: &logTransactionsKey, defaultValue: logTransactionsDefault as NSNumber) as Bool
        }
        set {
            associatedValue(self, key: &logTransactionsKey, value: NSNumber(bool: newValue))
            
            logUpdate("logTransactions", value: newValue)
        }
    }
    
    @inline(__always)
    private
    func logUpdate<T>(funcName: String, value: T) {
        logTrace(String(reflecting: self.dynamicType), level: 2) { "Model: \"\(funcName)\" value changed to \"\(value)\"" }
    }
}