//
//  MGConnectActionMessage.m
//  Connect
//
//  Created by Tony Stone on 5/27/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectActionMessage.h"
#import "MGConnectEmptyActionMessage.h"
#import "MGConnectManagedObjectActionMessage.h"
#import "MGConnectDictionaryActionMessage.h"

@implementation MGConnectActionMessage

static MGConnectActionMessage * emptyActionMessage;

+ (void)initialize {
    
    if (self == [MGConnectActionMessage class]) {
        emptyActionMessage = [[MGConnectEmptyActionMessage alloc] init];
    }
}

+ (MGConnectActionMessage *) actionMessage  {
    return emptyActionMessage;
}

+ (MGConnectActionMessage *) actionMessageWithManagedObject: (NSManagedObject *) managedObject  {
    return [[MGConnectManagedObjectActionMessage alloc] initWithManagedObject: managedObject];
}

+ (MGConnectActionMessage *) actionMessageWithDictionary: (NSDictionary *) valuesAndKeys updatedValueKeys: (NSArray *) updatedValueKeys {
    return [[MGConnectDictionaryActionMessage alloc] initWithValuesAndKeys: valuesAndKeys updatedValueKeys: updatedValueKeys];
}

- (NSDictionary *) valuesAndKeys {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (NSArray *) updatedValueKeys {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

@end
