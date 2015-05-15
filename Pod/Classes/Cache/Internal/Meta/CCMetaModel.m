//
// Created by Tony Stone on 4/30/15.
//

#import "CCMetaModel.h"

#define kDefaultRefreshType @"C"

@implementation CCMetaModel

    + (NSManagedObjectModel *) managedObjectModel {

        static NSManagedObjectModel * managedObjectModel = nil;

        if (!managedObjectModel) {

            NSArray * modelEntities = @[[self createRefreshStatus], [self createTransactionLogRecordEntity]];

            managedObjectModel = [[NSManagedObjectModel alloc] init];
            [managedObjectModel setEntities: modelEntities];

            [managedObjectModel setVersionIdentifiers: [NSSet setWithObject: @(1)]];
        }

        return managedObjectModel;
    }

    + (NSEntityDescription *) createTransactionLogRecordEntity {

        NSMutableArray * attributes = [[NSMutableArray alloc] init];

        NSAttributeDescription * sequenceNumber = [[NSAttributeDescription alloc] init];
        [sequenceNumber setName: @"sequenceNumber"];
        [sequenceNumber setOptional:NO];
        [sequenceNumber setAttributeType: NSInteger32AttributeType];
        [attributes addObject: sequenceNumber];

        NSAttributeDescription * previousSequenceNumber = [[NSAttributeDescription alloc] init];
        [previousSequenceNumber setName: @"previousSequenceNumber"];
        [previousSequenceNumber setOptional:NO];
        [previousSequenceNumber setAttributeType: NSInteger32AttributeType];
        [attributes addObject: previousSequenceNumber];

        NSAttributeDescription * transactionID = [[NSAttributeDescription alloc] init];
        [transactionID setName: @"transactionID"];
        [transactionID setOptional:NO];
        [transactionID setAttributeType: NSStringAttributeType];
        [attributes addObject: transactionID];

        NSAttributeDescription * timestamp = [[NSAttributeDescription alloc] init];
        [timestamp setName: @"timestamp"];
        [timestamp setOptional:NO];
        [timestamp setAttributeType: NSDateAttributeType];
        [attributes addObject: timestamp];

        NSAttributeDescription * type = [[NSAttributeDescription alloc] init];
        [type setName: @"type"];
        [type setOptional:NO];
        [type setAttributeType: NSStringAttributeType];
        [attributes addObject: type];

        NSAttributeDescription * updateEntityName = [[NSAttributeDescription alloc] init];
        [updateEntityName setName: @"updateEntityName"];
        [updateEntityName setOptional:YES];
        [updateEntityName setAttributeType: NSStringAttributeType];
        [attributes addObject: updateEntityName];

        NSAttributeDescription * updateUniqueID = [[NSAttributeDescription alloc] init];
        [updateUniqueID setName: @"updateUniqueID"];
        [updateUniqueID setOptional:NO];
        [updateUniqueID setAttributeType: NSStringAttributeType];
        [attributes addObject: updateUniqueID];

        NSAttributeDescription * updateData = [[NSAttributeDescription alloc] init];
        [updateData setName: @"updateData"];
        [updateData setOptional: YES];
        [updateData setAttributeType: NSTransformableAttributeType];
        [attributes addObject: updateData];

        NSEntityDescription * entity = [[NSEntityDescription alloc] init];
        [entity setName: @"CCMetaLogEntry"];
        [entity setManagedObjectClassName: @"CCMetaLogEntry"];

        [entity setProperties: attributes];

        return entity;
    }

    + (NSEntityDescription *) createRefreshStatus {

        NSMutableArray * attributes = [[NSMutableArray alloc] init];

        NSAttributeDescription * name = [[NSAttributeDescription alloc] init];
        [name setName: @"name"];
        [name setOptional:NO];
        [name setAttributeType: NSStringAttributeType];
        [attributes addObject: name];

        NSAttributeDescription * type = [[NSAttributeDescription alloc] init];
        [type setName: @"type"];
        [type setOptional:NO];
        [type setAttributeType: NSStringAttributeType];
        [type setDefaultValue: kDefaultRefreshType];
        [attributes addObject: type];

        NSAttributeDescription * scope = [[NSAttributeDescription alloc] init];
        [scope setName: @"scope"];
        [scope setOptional:YES];
        [scope setAttributeType: NSStringAttributeType];
        [scope setIndexed: YES];
        [attributes addObject: scope];

        NSAttributeDescription * lastSyncError = [[NSAttributeDescription alloc] init];
        [lastSyncError setName: @"lastSyncError"];
        [lastSyncError setOptional: YES];
        [lastSyncError setAttributeType: NSTransformableAttributeType];
        [attributes addObject: lastSyncError];

        NSAttributeDescription * lastSyncStatus = [[NSAttributeDescription alloc] init];
        [lastSyncStatus setName: @"lastSyncStatus"];
        [lastSyncStatus setOptional:YES];
        [lastSyncStatus setAttributeType: NSInteger32AttributeType];
        [attributes addObject: lastSyncStatus];

        NSAttributeDescription * lastSyncTime = [[NSAttributeDescription alloc] init];
        [lastSyncTime setName: @"lastSyncTime"];
        [lastSyncTime setOptional:YES];
        [lastSyncTime setAttributeType: NSDateAttributeType];
        [attributes addObject: lastSyncTime];

        NSEntityDescription * entity = [[NSEntityDescription alloc] init];
        [entity setName: @"CCRefreshStatus"];
        [entity setManagedObjectClassName: @"CCRefreshStatus"];
        [entity setProperties: attributes];

        return entity;
    }


@end