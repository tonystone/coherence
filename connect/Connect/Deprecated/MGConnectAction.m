//
//  MGConnectAction.m
//  Connect
//
//  Created by Tony Stone on 5/24/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectAction.h"
#import "MGConnectActionMessage.h"

@implementation MGConnectAction {
    NSString       * name;
    NSMutableArray * dependencies;
}

- (id) initWithName:(NSString *) aName {
    
    if ((self = [super init])) {
        name         = aName;
        dependencies = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *) name {
    return name;
}

- (NSArray *) dependencies {
    return [NSArray arrayWithArray: dependencies];
}

- (void) addDependency:(id <MGConnectAction>)action {
    [dependencies addObject: action];
}

- (void) removeDependency:(id <MGConnectAction>)action {
    [dependencies removeObject: action];
}

- (MGConnectActionCompletionStatus) execute: (id) userData inMessage: (MGConnectActionMessage *) inMessage error:(NSError *__autoreleasing *)error {
    [self doesNotRecognizeSelector: _cmd];
    
    return MGConnectActionCompletionStatusFailed;
}

- (NSString *) description {
    return [NSString stringWithFormat: @"<%@: %p> \r{\r\tname: %@\r\tdependencies: %u\r}\r", NSStringFromClass([self class]), self, [self name], [[self dependencies] count]];
}

@end
