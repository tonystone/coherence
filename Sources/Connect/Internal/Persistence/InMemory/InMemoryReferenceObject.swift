//
//  InMemoryReferenceObject.swift
//  Pods
//
//  Created by Tony Stone on 8/10/16.
//
//

//import Foundation
//import CoreData
//
//internal class InMemoryReferenceObject : NSIncrementalStoreNode {
//    
//    internal enum Errors: Error {
//        case relationshipNotFoundError(message: String)
//    }
//    
//    init(anObject: NSManagedObject, version: UInt64) {
//        
//        let attributes = anObject.entity.attributesByName.keys
//        var values     = [String : Any]()
//        //
//        // Only take the none nil attributes, skip all relationships
//        //
//        for attribute in attributes {
//            if let value = anObject.primitiveValue(forKey: attribute) {
//                values[attribute] = value
//            }
//        }
//        super.init(objectID: anObject.objectID, withValues: values, version: version)
//    }
//    
//    func relationshipFaultValue(_ relationship: NSRelationshipDescription) throws -> AnyObject {
//        
//        if let relationshipValue = self.value(for: relationship) {
//            
//            if relationship.isToMany, let relationshipValue = relationshipValue as? [AnyObject] {
//                
//                var result = Set<NSObject>()
//                
//                for referenceObject in relationshipValue {
//                    result.insert(referenceObject.objectID)
//                }
//                return result
//                
//            } else if let managedObject = relationshipValue as? NSManagedObject {
//                return managedObject.objectID
//            }
//        }
//        throw Errors.relationshipNotFoundError(message: "Relationship \(relationship.name) not found on objectID \(self.objectID)")
//    }
//    
//    func update(withObject managedObject: NSManagedObject, version: UInt64) {
//
//        let attributes =  managedObject.entity.attributesByName.keys
//        var values     =  [String : AnyObject]()
//        //
//        // Only take the none nil attributes, skip all relationships
//        //
//        for attribute in attributes {
//
//            if let value = managedObject.primitiveValue(forKey: attribute) {
//                values[attribute] = value
//            }
//        }
//        super.update(withValues: values, version: version)
//    }
//}
