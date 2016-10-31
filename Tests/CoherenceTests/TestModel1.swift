//
//  TestModel.swift
//  Coherence
//
//  Created by Tony Stone on 10/30/16.
//  Copyright © 2016 Tony Stone. All rights reserved.
//
import Foundation
import CoreData

internal class TestModel1: NSManagedObjectModel {
    
    override init() {
        super.init()
        
        self.entities = [self.userEntity()]
        self.versionIdentifiers = [1]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func userEntity() -> NSEntityDescription {
        
        var attributes = [NSAttributeDescription]()
        
        var attribute = NSAttributeDescription()
        attribute.name = "firstName"
        attribute.isOptional = true
        attribute.attributeType = NSAttributeType.stringAttributeType
        attributes.append(attribute)
        
        attribute = NSAttributeDescription()
        attribute.name = "lastName"
        attribute.isOptional = true
        attribute.attributeType = NSAttributeType.stringAttributeType
        attributes.append(attribute)
        
        attribute = NSAttributeDescription()
        attribute.name = "userName"
        attribute.isOptional = true
        attribute.attributeType = NSAttributeType.stringAttributeType
        attributes.append(attribute)
        
        let entity = NSEntityDescription()
        entity.name = "User"
        entity.managedObjectClassName = "User"
        
        entity.properties = attributes
        
        return entity;
    }
}

