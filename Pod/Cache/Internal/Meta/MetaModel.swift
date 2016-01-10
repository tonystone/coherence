/**
 *   MetaModel.swift
 *
 *   Copyright 2015 Tony Stone
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *
 *   Created by Tony Stone on 12/10/15.
 */
import Foundation
import CoreData

internal class MetaModel: NSManagedObjectModel {
    
    override init() {
        super.init()

        self.entities = [self.metaLogEntry(), self.refreshStatus()]
        self.versionIdentifiers = [1]
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func metaLogEntry() -> NSEntityDescription {

        var attributes = [NSAttributeDescription]()

        let sequenceNumber = NSAttributeDescription()
        sequenceNumber.name = "sequenceNumber"
        sequenceNumber.optional = false
        sequenceNumber.attributeType = NSAttributeType.Integer32AttributeType
        attributes.append(sequenceNumber)

        let previousSequenceNumber = NSAttributeDescription()
        previousSequenceNumber.name = "previousSequenceNumber"
        previousSequenceNumber.optional = false
        previousSequenceNumber.attributeType = NSAttributeType.Integer32AttributeType
        attributes.append(previousSequenceNumber)

        let transactionID = NSAttributeDescription()
        transactionID.name = "transactionID"
        transactionID.optional = false
        transactionID.attributeType = NSAttributeType.StringAttributeType
        attributes.append(transactionID)

        let timestamp = NSAttributeDescription()
        timestamp.name = "timestamp"
        timestamp.optional = false
        timestamp.attributeType = NSAttributeType.DateAttributeType
        attributes.append(timestamp)

        let type = NSAttributeDescription()
        type.name = "type"
        type.optional = false
        type.attributeType = NSAttributeType.Integer32AttributeType
        attributes.append(type)

        let updateEntityName = NSAttributeDescription()
        updateEntityName.name = "updateEntityName"
        updateEntityName.optional = true
        updateEntityName.attributeType = NSAttributeType.StringAttributeType
        attributes.append(updateEntityName)

        let updateObjectID = NSAttributeDescription()
        updateObjectID.name = "updateObjectID"
        updateObjectID.optional = true
        updateObjectID.attributeType = NSAttributeType.StringAttributeType
        attributes.append(updateObjectID)

        let updateUniqueID = NSAttributeDescription()
        updateUniqueID.name = "updateUniqueID"
        updateUniqueID.optional = true
        updateUniqueID.attributeType = NSAttributeType.StringAttributeType
        attributes.append(updateUniqueID)

        let updateData = NSAttributeDescription()
        updateData.name = "updateData"
        updateData.optional = true
        updateData.attributeType = NSAttributeType.TransformableAttributeType
        attributes.append(updateData)

        let entity = NSEntityDescription()
        entity.name = "MetaLogEntry"
        entity.managedObjectClassName = "MetaLogEntry"

        entity.properties = attributes

        return entity;
    }

    private func refreshStatus() -> NSEntityDescription {

        var attributes = [NSAttributeDescription]()

        let name = NSAttributeDescription()
        name.name = "name"
        name.optional = false
        name.attributeType = NSAttributeType.StringAttributeType
        attributes.append(name)

        let type = NSAttributeDescription()
        type.name = "type"
        type.optional = false
        type.attributeType = NSAttributeType.StringAttributeType
//        type.defaultValue = kDefaultRefreshType
        attributes.append(type)

        let scope = NSAttributeDescription()
        scope.name = "scope"
        scope.optional = true
        scope.attributeType = NSAttributeType.StringAttributeType
        scope.indexed = true
        attributes.append(scope)

        let lastSyncError = NSAttributeDescription()
        lastSyncError.name = "lastSyncError"
        lastSyncError.optional = true
        lastSyncError.attributeType = NSAttributeType.TransformableAttributeType
        attributes.append(lastSyncError)

        let lastSyncStatus = NSAttributeDescription()
        lastSyncStatus.name = "lastSyncStatus"
        lastSyncStatus.optional = true
        lastSyncStatus.attributeType = NSAttributeType.Integer32AttributeType
        attributes.append(lastSyncStatus)

        let lastSyncTime = NSAttributeDescription()
        lastSyncTime.name = "lastSyncTime"
        lastSyncTime.optional = true
        lastSyncTime.attributeType = NSAttributeType.DateAttributeType
        attributes.append(lastSyncTime)

        let entity = NSEntityDescription()
        entity.name = "RefreshStatus"
        entity.managedObjectClassName = "RefreshStatus"

        entity.properties = attributes

        return entity;
    }

}
