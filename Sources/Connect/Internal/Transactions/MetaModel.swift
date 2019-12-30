///
///  MetaModel.swift
///
///  Copyright 2015 Tony Stone
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
///  Created by Tony Stone on 12/10/15.
///
import Foundation
import CoreData

internal class MetaModel: NSManagedObjectModel {

    internal static let metaConfigurationName = "_meta"

    override init() {
        super.init()

        self.entities = [self.metaLogEntry(), self.refreshStatus()]

        self.setEntities(self.entities, forConfigurationName: MetaModel.metaConfigurationName)

        self.versionIdentifiers = [1]
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    fileprivate func metaLogEntry() -> NSEntityDescription {

        var attributes = [NSAttributeDescription]()

        let sequenceNumber = NSAttributeDescription()
        sequenceNumber.name = "sequenceNumber"
        sequenceNumber.isOptional = false
        sequenceNumber.attributeType = NSAttributeType.integer32AttributeType
        attributes.append(sequenceNumber)

        let previousSequenceNumber = NSAttributeDescription()
        previousSequenceNumber.name = "previousSequenceNumber"
        previousSequenceNumber.isOptional = false
        previousSequenceNumber.attributeType = NSAttributeType.integer32AttributeType
        attributes.append(previousSequenceNumber)

        let transactionID = NSAttributeDescription()
        transactionID.name = "transactionID"
        transactionID.isOptional = false
        transactionID.attributeType = NSAttributeType.stringAttributeType
        attributes.append(transactionID)

        let timestamp = NSAttributeDescription()
        timestamp.name = "timestamp"
        timestamp.isOptional = false
        timestamp.attributeType = NSAttributeType.dateAttributeType
        attributes.append(timestamp)

        let type = NSAttributeDescription()
        type.name = "type"
        type.isOptional = false
        type.attributeType = NSAttributeType.integer32AttributeType
        attributes.append(type)

        let updateEntityName = NSAttributeDescription()
        updateEntityName.name = "updateEntityName"
        updateEntityName.isOptional = true
        updateEntityName.attributeType = NSAttributeType.stringAttributeType
        attributes.append(updateEntityName)

        let updateObjectID = NSAttributeDescription()
        updateObjectID.name = "updateObjectID"
        updateObjectID.isOptional = true
        updateObjectID.attributeType = NSAttributeType.stringAttributeType
        attributes.append(updateObjectID)

        let updateUniqueID = NSAttributeDescription()
        updateUniqueID.name = "updateUniqueID"
        updateUniqueID.isOptional = true
        updateUniqueID.attributeType = NSAttributeType.stringAttributeType
        attributes.append(updateUniqueID)

        let updateData = NSAttributeDescription()
        updateData.name = "updateData"
        updateData.isOptional = true
        updateData.attributeType = NSAttributeType.transformableAttributeType
        updateData.valueTransformerName = "NSSecureUnarchiveFromData"
        attributes.append(updateData)

        let entity = NSEntityDescription()
        entity.name = "MetaLogEntry"
        entity.managedObjectClassName = "MetaLogEntry"

        entity.properties = attributes

        return entity;
    }

    fileprivate func refreshStatus() -> NSEntityDescription {

        var attributes = [NSAttributeDescription]()

        let name = NSAttributeDescription()
        name.name = "name"
        name.isOptional = false
        name.attributeType = NSAttributeType.stringAttributeType
        attributes.append(name)

        let type = NSAttributeDescription()
        type.name = "type"
        type.isOptional = false
        type.attributeType = NSAttributeType.stringAttributeType
        attributes.append(type)

        let scope = NSAttributeDescription()
        scope.name = "scope"
        scope.isOptional = true
        scope.attributeType = NSAttributeType.stringAttributeType
        attributes.append(scope)

        let lastSyncError = NSAttributeDescription()
        lastSyncError.name = "lastSyncError"
        lastSyncError.isOptional = true
        lastSyncError.attributeType = NSAttributeType.transformableAttributeType
        lastSyncError.valueTransformerName = "NSSecureUnarchiveFromData"
        attributes.append(lastSyncError)

        let lastSyncStatus = NSAttributeDescription()
        lastSyncStatus.name = "lastSyncStatus"
        lastSyncStatus.isOptional = true
        lastSyncStatus.attributeType = NSAttributeType.integer32AttributeType
        attributes.append(lastSyncStatus)

        let lastSyncTime = NSAttributeDescription()
        lastSyncTime.name = "lastSyncTime"
        lastSyncTime.isOptional = true
        lastSyncTime.attributeType = NSAttributeType.dateAttributeType
        attributes.append(lastSyncTime)

        let entity = NSEntityDescription()
        entity.name = "RefreshStatus"
        entity.managedObjectClassName = "RefreshStatus"

        entity.properties = attributes

        return entity;
    }

}
