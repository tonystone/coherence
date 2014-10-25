//
//  MGTransactionLogRecord.h
//  MGConnect
//
//  Created by Tony Stone on 4/16/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

/**
 TransactionID Type
 */
typedef NSString MGTransactionID;

/**
 LogRecord types
 */
enum  {
    MGTransactionLogRecordTypeBeginMarker = 0,
    MGTransactionLogRecordTypeEndMarker   = 1,
    MGTransactionLogRecordTypeInsert      = 2,
    MGTransactionLogRecordTypeUpdate      = 3,
    MGTransactionLogRecordTypeDelete      = 4,
};
typedef NSUInteger MGTransactionLogRecordType;


/**
 TransactionLogRecord structure
 */
@interface MGTransactionLogRecord : NSManagedObject

@property (nonatomic, strong) NSNumber        * sequenceNumber;            // Numerical sequence number of this record
@property (nonatomic, strong) NSNumber        * previousSequenceNumber;    // Previous sequence number, usually sequenceNumber -1 but not guarenteed
@property (nonatomic, strong) MGTransactionID * transactionID;             // TransactionLogRecord transactionRecord objectID in URI String representation
@property (nonatomic, strong) NSDate          * timestamp;                 // Timestamp of when this record was put in
@property (nonatomic, strong) NSNumber        * type;                      // The type of transactionRecord.  See MGTransactioNLogRecordType for more info

@property (nonatomic, strong) NSString        * updateEntityName;          // The entity that was changed
@property (nonatomic, strong) NSString        * updateObjectID;            // The objectID in URI String representation
@property (nonatomic, strong) NSString        * updateUniqueID;            // The unique ID of this object as defined by the entity
@property (nonatomic, strong) id                updateData;                // A structure containing the changes

@end

/**
 NOTE: the attributes in this class are all public because
       it is considered a strcuture.  We had to make this a class
       to suite the CoreData requirements.
 */
@interface MGTransactionLogRecordInsertData : NSObject <NSCoding> {
@public
    NSDictionary * attributesAndValues;
}
@end

/**
 NOTE: the attributes in this class are all public because
 it is considered a strcuture.  We had to make this a class
 to suite the CoreData requirements.
 */
@interface MGTransactionLogRecordUpdateData : NSObject <NSCoding>  {
@public
    NSDictionary * attributesAndValues;
    NSArray      * updatedAttributes;
}
@end

/**
 NOTE: the attributes in this class are all public because
 it is considered a strcuture.  We had to make this a class
 to suite the CoreData requirements.
 */
@interface MGTransactionLogRecordDeleteData : NSObject <NSCoding>
@end

