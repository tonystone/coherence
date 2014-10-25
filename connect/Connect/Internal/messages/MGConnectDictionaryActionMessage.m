//
//  MGConnectDictionaryActionMessage.m
//  Connect
//
//  Created by Tony Stone on 5/28/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectDictionaryActionMessage.h"

@implementation MGConnectDictionaryActionMessage {
    NSArray           * updatedValueKeys;
    NSDictionary      * valuesAndKeys;
}

- (id) initWithValuesAndKeys:(NSDictionary *) theValuesAndKeys updatedValueKeys:(NSArray *) theUpdatedValueKeys {
    
    NSParameterAssert(theValuesAndKeys != nil);
    NSParameterAssert(theUpdatedValueKeys != nil);
    
    if ((self = [super init])) {
        updatedValueKeys = theUpdatedValueKeys;
        valuesAndKeys    = theValuesAndKeys;
    }
    return self;
}

- (NSArray *) updatedValueKeys {
    return updatedValueKeys;
}

- (NSDictionary *)valuesAndKeys {
    return valuesAndKeys;
}


@end
