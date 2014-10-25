//
//  MGTransactionLogRecord.m
//  MGConnect
//
//  Created by Tony Stone on 4/16/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGTransactionLogRecord.h"

@implementation MGTransactionLogRecord

@dynamic transactionID;
@dynamic sequenceNumber;
@dynamic previousSequenceNumber;
@dynamic timestamp;
@dynamic type;
@dynamic persistentStoreIdentifier;
@dynamic entityName;
@dynamic updatedObjectID;
@dynamic updatedObjectUniqueID;
@dynamic updatedObjectData;

@end

#define kAttributesAndValues @"attributesAndValues"
#define kUpdatedAttributes   @"updatedAttributes"

@implementation MGTransactionLogRecordInsertData

- (id) init {
    if ((self = [super init])) {
        attributesAndValues = nil;
    }
    return self;
}

- (id) initWithCoder: (NSCoder *) aDecoder {
    if ((self = [super init])) {
        attributesAndValues = [aDecoder decodeObjectOfClass: [NSDictionary class] forKey: kAttributesAndValues];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) aCoder {
    [aCoder encodeObject: attributesAndValues forKey: kAttributesAndValues];
}

@end

@implementation MGTransactionLogRecordUpdateData

- (id) init {
    if ((self = [super init])) {
        attributesAndValues = nil;
        updatedAttributes   = nil;
    }
    return self;
}

- (id) initWithCoder: (NSCoder *) aDecoder {
    if ((self = [super init])) {
        attributesAndValues = [aDecoder decodeObjectOfClass: [NSDictionary class] forKey: kAttributesAndValues];
        updatedAttributes   = [aDecoder decodeObjectOfClass: [NSArray class]      forKey: kUpdatedAttributes];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) aCoder {
    [aCoder encodeObject: attributesAndValues forKey: kAttributesAndValues];
}
@end

@implementation MGTransactionLogRecordDeleteData

- (id) initWithCoder: (NSCoder *) aDecoder {
    return (self = [super init]);
}

- (void) encodeWithCoder: (NSCoder *) aCoder {
}
@end