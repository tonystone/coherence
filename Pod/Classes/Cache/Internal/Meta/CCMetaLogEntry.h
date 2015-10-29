/**
 *   CCMetaLogEntry.h
 *
 *   Copyright 2015 The Climate Corporation
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
 *   Created by Tony Stone on 4/30/15.
 */
#import <CoreData/CoreData.h>

/**
    TransactionID Type
*/
typedef NSString CCTransactionID;

/**
    LogEntry types
*/

extern NSString const * CCMetaLogEntryTypeBeginMarker;
extern NSString const * CCMetaLogEntryTypeEndMarker;
extern NSString const * CCMetaLogEntryTypeInsert;
extern NSString const * CCMetaLogEntryTypeUpdate;
extern NSString const * CCMetaLogEntryTypeDelete;

/**
    CCMetaLogEntry structure
*/
@interface CCMetaLogEntry : NSManagedObject

    @property (nonatomic, strong) NSNumber        * sequenceNumber;            // Numerical sequence number of this record
    @property (nonatomic, strong) NSNumber        * previousSequenceNumber;    // Previous sequence number, usually sequenceNumber -1 but not guaranteed
    @property (nonatomic, strong) CCTransactionID * transactionID;             // CCMetaLogEntry transactionEntry objectID in URI String representation
    @property (nonatomic, strong) NSDate          * timestamp;                 // Timestamp of when this record was put in
    @property (nonatomic, strong) NSString  const * type;                      // The type of transactionRecord.  See CCMetaLogEntryType for more info

    @property (nonatomic, strong) NSString        * updateEntityName;          // The entity that was changed
    @property (nonatomic, strong) NSString        * updateObjectID;            // The objectID in URI String representation
    @property (nonatomic, strong) NSString        * updateUniqueID;            // The unique ID of this object as defined by the entity
    @property (nonatomic, strong) id                updateData;                // A structure containing the changes

@end

/**
    NOTE: the attributes in this class are all public because
    it is considered a structure.  We had to make this a class
    to suite the CoreData requirements.
*/
@interface CCMetaLogEntryInsertData : NSObject <NSCoding> {
    @public
        NSDictionary * attributesAndValues;
    }
@end

/**
    NOTE: the attributes in this class are all public because
    it is considered a structure.  We had to make this a class
    to suite the CoreData requirements.
*/
@interface CCMetaLogEntryUpdateData : NSObject <NSCoding>  {
    @public
        NSDictionary * attributesAndValues;
        NSArray      * updatedAttributes;
    }
@end

/**
    NOTE: the attributes in this class are all public because
    it is considered a structure.  We had to make this a class
    to suite the CoreData requirements.
*/
@interface CCMetaLogEntryDeleteData : NSObject <NSCoding>
@end