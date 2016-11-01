///
///  TestModel1.swift
///
///  Copyright 2016 The Climate Corporation
///  Copyright 2016 Tony Stone
///
///  Licensed under the Apache License, Version 2.0 (the "License");
///  you may not use this file except in compliance with the License.
///  You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///  Unless required by applicable law or agreed to in writing, software
///  distributed under the License is distributed on an "AS IS" BASIS,
///  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///  See the License for the specific language governing permissions and
///  limitations under the License.
///
///  Created by Tony Stone on 10/30/16.
///
import Foundation
import CoreData

internal class TestModel1: NSManagedObjectModel {
    
    override init() {
        super.init()
        
        let userEntity = self.userEntity()
        
        self.entities = [userEntity]
        
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
        attribute.isOptional = false
        attribute.attributeType = NSAttributeType.stringAttributeType
        attributes.append(attribute)
        
        let entity = NSEntityDescription()
        entity.name = "User"
        entity.managedObjectClassName = "User"
        
        entity.properties = attributes
        
        return entity;
    }
}

