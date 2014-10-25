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
    MGTransactionLogRecordTypeBeginMarker = 1,
    MGTransactionLogRecordTypeInsert      = 2,
    MGTransactionLogRecordTypeUpdate      = 3,
    MGTransactionLogRecordTypeDelete      = 4,
    MGTransactionLogRecordTypeEndMarker   = 5,
};
typedef NSUInteger MGTransactionLogRecordType;


/**
 TransactionLogRecord structure
 */
@interface MGTransactionLogRecord : NSManagedObject

//
// Transaction Identification
//
@property (nonatomic, strong) NSNumber        * sequenceNumber;            // Numerical sequence number of this record
@property (nonatomic, strong) NSNumber        * previousSequenceNumber;    // Previous sequence number, usually sequenceNumber -1 but not guarenteed
@property (nonatomic, strong) MGTransactionID * transactionID;             // TransactionLogRecord transactionRecord objectID in URI String representation
@property (nonatomic, strong) NSDate          * timestamp;                 // Timestamp of when this record was put in
@property (nonatomic, strong) NSNumber        * type;                      // The type of transactionRecord.  See MGTransactioNLogRecordType for more info

//
// Routing
//
@property (nonatomic, strong) NSString        * persistentStoreIdentifier; // The persistent Store identifier that this change happended in
@property (nonatomic, strong) NSString        * entityName;                // The entity name that was changed

//
// Object Identification
//
@property (nonatomic, strong) NSString        * updatedObjectID;            // The objectID in URI String representation
@property (nonatomic, strong) NSString        * updatedObjectUniqueID;      // The unique ID of this object as defined by the entity

//
// Object change data
//
@property (nonatomic, strong) id                updatedObjectData;          // A structure containing the changes

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

