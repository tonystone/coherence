//
// Created by Tony Stone on 5/4/15.
//

#import <Foundation/Foundation.h>


typedef enum {
    CCJSONType_INSERT,
    CCJSONType_UPDATE,
    CCJSONType_FULL
} CCJSONType;

@protocol CCResource <NSObject>

    - (NSDictionary *) toJSONDictionary: (CCJSONType) type;

@end