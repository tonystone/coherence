//
// Created by Tony Stone on 4/30/15.
//

#import "CCMetaLogEntry.h"

NSString const * CCMetaLogEntryTypeBeginMarker = @"B";
NSString const * CCMetaLogEntryTypeEndMarker   = @"E";
NSString const * CCMetaLogEntryTypeInsert      = @"I";
NSString const * CCMetaLogEntryTypeUpdate      = @"U";
NSString const * CCMetaLogEntryTypeDelete      = @"D";

@implementation CCMetaLogEntry

    @dynamic transactionID;
    @dynamic sequenceNumber;
    @dynamic previousSequenceNumber;
    @dynamic timestamp;
    @dynamic type;
    @dynamic updateEntityName;
    @dynamic updateObjectID;
    @dynamic updateUniqueID;
    @dynamic updateData;

@end

#define kAttributesAndValues @"attributesAndValues"
#define kUpdatedAttributes   @"updatedAttributes"

@implementation CCMetaLogEntryInsertData

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

@implementation CCMetaLogEntryUpdateData

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
        [aCoder encodeObject: updatedAttributes   forKey: kUpdatedAttributes];
    }
@end

@implementation CCMetaLogEntryDeleteData

    - (id) initWithCoder: (NSCoder *) aDecoder {
        return (self = [super init]);
    }

    - (void) encodeWithCoder: (NSCoder *) aCoder {
    }
@end