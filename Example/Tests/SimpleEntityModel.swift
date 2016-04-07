//
//  SimpleEntityModel.swift
//
//
//  Created by Paul Chang on 4/6/16.
//
//
import Foundation
import CoreData

internal class SimpleEntityModel: NSManagedObjectModel {
    
    override init() {
        super.init()
        
        self.entities = [self.simpleEntity()]
        self.versionIdentifiers = [1]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func simpleEntity() -> NSEntityDescription {
        
        var attributes = [NSAttributeDescription]()
        
        let userId = NSAttributeDescription()
        userId.name = "userId"
        userId.optional = false
        userId.attributeType = NSAttributeType.Integer32AttributeType
        attributes.append(userId)
        
        let transactionID = NSAttributeDescription()
        transactionID.name = "transactionID"
        transactionID.optional = false
        transactionID.attributeType = NSAttributeType.StringAttributeType
        attributes.append(transactionID)
        
        let entity = NSEntityDescription()
        entity.name = "SimpleEntity"
        entity.managedObjectClassName = "SimpleEntity"
        
        entity.properties = attributes
        
        return entity;
    }
}
