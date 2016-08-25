//
//  InMemoryReferenceObject.swift
//  Pods
//
//  Created by Tony Stone on 8/10/16.
//
//

import Foundation
import CoreData

internal class InMemoryReferenceObject : NSIncrementalStoreNode {
    
    internal enum Errors: ErrorType {
        case RelationshipNotFoundError(message: String)
    }
    
    init(anObject: NSManagedObject, version: UInt64) {
        
        let attributes = anObject.entity.attributesByName.keys
        var values     = [String : AnyObject]()
        //
        // Only take the none nil attributes, skip all relationships
        //
        for attribute in attributes {
            if let value = anObject.primitiveValueForKey(attribute) {
                values[attribute] = value
            }
        }
        super.init(objectID: anObject.objectID, withValues: values, version: version)
    }
    
    func relationshipFaultValue(relationship: NSRelationshipDescription) throws -> AnyObject {
        
        if let relationshipValue = self.valueForPropertyDescription(relationship) {
            
            if relationship.toMany, let relationshipValue = relationshipValue as? [AnyObject] {
                
                var result = Set<NSObject>()
                
                for referenceObject in relationshipValue {
                    result.insert(referenceObject.objectID)
                }
                return result
                
            } else if let managedObject = relationshipValue as? NSManagedObject {
                return managedObject.objectID
            }
        }
        throw Errors.RelationshipNotFoundError(message: "Relationship \(relationship.name) not found on objectID \(self.objectID)")
    }
    
    func update(withObject managedObject: NSManagedObject, version: UInt64) {

        let attributes =  managedObject.entity.attributesByName.keys
        var values     =  [String : AnyObject]()
        //
        // Only take the none nil attributes, skip all relationships
        //
        for attribute in attributes {

            if let value = managedObject.primitiveValueForKey(attribute) {
                values[attribute] = value
            }
        }
        super.updateWithValues(values, version: version)
    }
}