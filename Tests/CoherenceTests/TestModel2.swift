//
//  TestModel2.swift
//
//
//  Created by Paul Chang on 4/6/16.
//
//
import Foundation
import CoreData

internal class TestModel2: NSManagedObjectModel {
    
    override init() {
        super.init()
        
        self.entities = [self.simpleEntity()]
        self.versionIdentifiers = [1]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func simpleEntity() -> NSEntityDescription {
        
        var attributes = [NSAttributeDescription]()
        
        let userId = NSAttributeDescription()
        userId.name = "userId"
        userId.isOptional = false
        userId.attributeType = NSAttributeType.integer32AttributeType
        attributes.append(userId)
        
        let transactionID = NSAttributeDescription()
        transactionID.name = "transactionID"
        transactionID.isOptional = false
        transactionID.attributeType = NSAttributeType.stringAttributeType
        attributes.append(transactionID)
        
        let entity = NSEntityDescription()
        entity.name = "SimpleEntity"
        entity.managedObjectClassName = "SimpleEntity"
        
        entity.properties = attributes
        
        return entity;
    }
}
