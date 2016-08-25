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
            return associatedValue(self, key: &managedKey, defaultValue: self.managedObjectModel.stalenessInterval as NSNumber) as Bool
        }
        set {
            associatedValue(self, key: &managedKey, value: NSNumber(bool: newValue))
            
            logUpdate(__FUNCTION__, value: newValue)
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
            associatedValue(self, key: &stalenessIntervalKey, value: NSNumber(integer: newValue))
            
            logUpdate(__FUNCTION__, value: newValue)
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
            associatedValue(self, key: &logTransactionsKey, value: NSNumber(bool: newValue))
            
            logUpdate(__FUNCTION__, value: newValue)
        }
    }
    
    @inline(__always)
    private
    func logUpdate<T>(funcName: String, value: T) {
        logTrace(String(reflecting: self.dynamicType), level: 2) { "\(self.name ?? String(reflecting: self)): \"\(funcName)\" value changed to \"\(value)\"" }
    }
}






