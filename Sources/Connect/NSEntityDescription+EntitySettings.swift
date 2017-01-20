//
// Created by Tony Stone on 8/21/16.
//
import Foundation
import CoreData
import TraceLog


extension NSEntityDescription  {

    /**
        Is this entity managed by Connect?
     */
    public internal(set) var managed: Bool {
        get {
            return associatedValue(self, key: &managedKey, defaultValue: managedDefault as NSNumber) as Bool
        }
        set {
            associatedValue(self, key: &managedKey, value: NSNumber(value: newValue))
            
            logUpdate(#function, value: newValue)
        }
    }
    
    /**
        Sets the amount of time before the resource is updated again from the master source
     
        Note: if this value is not set at this level, the model value will be used.
     */
    public var stalenessInterval: Int {
        get {
            return associatedValue(self, key: &stalenessIntervalKey, defaultValue: self.managedObjectModel.stalenessInterval as NSNumber) as Int
        }
        set {
            associatedValue(self, key: &stalenessIntervalKey, value: NSNumber(value: newValue))
            
            logUpdate(#function, value: newValue)
        }
    }
    
    /**
        Should Connect log transactions for this entity?
     
        Note: if this value is not set at this level, the model value will be used.
    */
    public var logTransactions: Bool {
        get {
            return associatedValue(self, key: &logTransactionsKey, defaultValue: self.managedObjectModel.logTransactions as NSNumber) as Bool
        }
        set {
            associatedValue(self, key: &logTransactionsKey, value: NSNumber(value: newValue))
            
            logUpdate(#function, value: newValue)
        }
    }
    
    @inline(__always)
    fileprivate
    func logUpdate<T>(_ funcName: String, value: T) {
        logTrace(String(reflecting: type(of: self)), level: 2) { "\(self.name ?? String(reflecting: self)): \"\(funcName)\" value changed to \"\(value)\"" }
    }
}






