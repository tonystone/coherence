//
//  MGWebServiceInMessage.m
//  MGConnect
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWebServiceInMessage.h"

@implementation MGWebServiceInMessage  {
    NSMutableDictionary * parameters;
    NSMutableDictionary * headers;
    NSDictionary        * instanceData;
}

- (id) init {
    
    if ((self = [super init])) {
        parameters = [[NSMutableDictionary alloc] init];
        headers    = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSDictionary *) parameters {
    return [NSDictionary dictionaryWithDictionary: parameters];
}

- (NSDictionary *) headers {
    return [NSDictionary dictionaryWithDictionary: headers];
}

- (void) addValue: (NSString *) aValue forHeaderField: (NSString *) aHeader {
    NSString * currentValue = [headers objectForKey: aHeader];
    
    if (currentValue) {
        currentValue = [currentValue stringByAppendingFormat: @",%@", aValue];
    } else {
        currentValue = aValue;
    }
    
    [self setValue: currentValue forHeaderField: aHeader];
}

- (void) setValue: (NSString *) aValue forHeaderField: (NSString *) aHeader {
    [headers setValue: aValue forKey: aHeader];
}

- (void) addHeaders:(NSDictionary *) newHeaders {
    [headers addEntriesFromDictionary: newHeaders];
}

- (void) setValue: (NSString *) aValue forParameter: (NSString *) aParameter {
    [parameters setValue: aValue forKey: aParameter];
}

- (NSDictionary *) instanceData {
    return instanceData;
}

- (void) setInstanceData: (NSDictionary *) theData {
    if (instanceData != theData) {
        instanceData = theData;
    }
}

@end
