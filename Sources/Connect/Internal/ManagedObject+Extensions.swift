///
///  ManagedObject+Extensions.swift
///  Pods
///
///  Created by Tony Stone on 2/27/17.
///
///
import Swift
import CoreData

///
/// Internal Extensions on NSManagedObject
///
extension NSManagedObject {

    internal func uniqueueIDString() -> String? {
        if !self.entity.uniquenessAttributes.isEmpty {
            var uniqueID = ""
            for key in self.entity.uniquenessAttributes {
                uniqueID.append("\(self.primitiveValue(forKey: key) ?? "")")
            }
            return uniqueID
        }
        return nil
    }
}
