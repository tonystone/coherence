//
//  MGObjectProtocolValidator.m
//  Connect
//
//  Created by Tony Stone on 5/30/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGClassProtocolValidator.h"
#import "MGInitializationException.h"
#import "MGTraceLog.h"
#import <objc/runtime.h>

@implementation MGClassProtocolValidator

+ (void) validateClass: (Class) class forProtocols: (NSArray *) protocols {
    for (Protocol * protocol in  protocols) {
        [self validateClass: class forProtocol: protocol];
    }
}

+ (void) validateClass: (Class) class forProtocol: (Protocol *) protocol {
    
    if (![class conformsToProtocol: protocol]) {
        @throw [MGInitializationException exceptionWithName: @"Initialization Exception" reason: [NSString stringWithFormat: @"Class <%@> does not conform to protocol <%@>", NSStringFromClass(class), NSStringFromProtocol(protocol)] userInfo: nil];
    }
    
    unsigned int count;
    Protocol * __unsafe_unretained * protocolList = protocol_copyProtocolList(protocol, &count);
    
    for (int i = 0; i < count; i++) {
        [self validateClass: class forProtocol: protocolList[i]];
    }
    [self class: class implementsRequiredInstanceMethods: protocol];
}

+ (void) class: (Class) class implementsRequiredInstanceMethods: (Protocol *) protocol {
    unsigned int count;
    struct objc_method_description * methodDescriptions =  protocol_copyMethodDescriptionList(protocol, YES, YES,  &count);
    
    for (int i = 0; i < count; i++) {
        
        LogTrace(4,@"Validating class <%@> for required method \"%@\" for protocol <%@>", NSStringFromClass(class), NSStringFromSelector(methodDescriptions[i].name), NSStringFromProtocol(protocol));
        
        if (!class_respondsToSelector(class, methodDescriptions[i].name)) {
            @throw [MGInitializationException exceptionWithName: @"Initialization Exception" reason: [NSString stringWithFormat: @"Class <%@> does not implement the required method \"%@\" for protocol <%@>", NSStringFromClass(class), NSStringFromSelector(methodDescriptions[i].name), NSStringFromProtocol(protocol)] userInfo: nil];
        }
    }
}

@end
