//
// Created by Tony Stone on 4/30/15.
//

#import <CoreData/CoreData.h>




/**
    TransactionID Type
*/
typedef NSString CCTransactionID;

/**
    LogEntry types
*/
enum  {
    CCMetaLogEntryTypeBeginMarker = 0,
    CCMetaLogEntryTypeEndMarker   = 1,
    CCMetaLogEntryTypeInsert      = 2,
    CCMetaLogEntryTypeUpdate      = 3,
    CCMetaLogEntryTypeDelete      = 4,
};
typedef NSUInteger CCMetaLogEntryType;


/**
    CCMetaLogEntry structure
*/
@interface CCMetaLogEntry : NSManagedObject

    @property (nonatomic, strong) NSNumber        * sequenceNumber;            // Numerical sequence number of this record
    @property (nonatomic, strong) NSNumber        * previousSequenceNumber;    // Previous sequence number, usually sequenceNumber -1 but not guaranteed
    @property (nonatomic, strong) CCTransactionID * transactionID;             // CCMetaLogEntry transactionEntry objectID in URI String representation
    @property (nonatomic, strong) NSDate          * timestamp;                 // Timestamp of when this record was put in
    @property (nonatomic, strong) NSNumber        * type;                      // The type of transactionRecord.  See CCMetaLogEntryType for more info

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