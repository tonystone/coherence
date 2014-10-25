//
//  MGWSDLInterface.m
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLInterface.h"

@implementation MGWSDLInterface {
    NSMutableDictionary * extendedInterfaces;
    NSMutableDictionary * interfaceFaults;
    NSMutableDictionary * interfaceOperations;
}

- (NSDictionary *) extendedInterfaces {
    return [NSDictionary dictionaryWithDictionary: extendedInterfaces];
}

- (NSDictionary *) interfaceFaults {
    return [NSDictionary dictionaryWithDictionary: interfaceFaults];
}

- (NSDictionary *) interfaceOperations {
    return [NSDictionary dictionaryWithDictionary: interfaceOperations];
}

- (NSString *) description {
    return [self descriptionForLevel: 0];
}

- (NSString *) descriptionForLevel:(NSUInteger)level {

    NSMutableString * description = [NSMutableString stringWithFormat: @"<%@ : %p>: ", NSStringFromClass([self class]), self];

    [description appendString: [self dictionaryString: extensionProperties  name: @"extensionProperties" level: level+1]];
    [description appendString: [self dictionaryString: extensionElements    name: @"extensionElements"   level: level+1]];
    [description appendString: [self dictionaryString: extendedInterfaces   name: @"extendedInterfaces"  level: level+1]];
    [description appendString: [self dictionaryString: interfaceFaults      name: @"interfaceFaults"     level: level+1]];
    [description appendString: [self dictionaryString: interfaceOperations  name: @"interfaceOperations" level: level+1]];

    
    return description;
}

@end


#import "MGWSDLInterfaceFault.h"
#import "MGWSDLInterfaceOperation.h"

@implementation MGWSDLInterface (Initialization)

- (id) initWithName: (NSString *) name {
    
    NSParameterAssert(name != nil);
    
    if ((self = [super initWithName: name])) {
        extendedInterfaces  = [[NSMutableDictionary alloc] init];
        interfaceFaults     = [[NSMutableDictionary alloc] init];
        interfaceOperations = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) addExtendedInterface: (MGWSDLInterface *) anInterface {
    [extendedInterfaces setValue: anInterface forKey: [anInterface name]];
}

- (void) addInterfaceFault: (MGWSDLInterfaceFault *) aFault {
    [interfaceFaults setValue: aFault forKey: [aFault name]];
    [aFault setParent: self];
}

- (void) addInterfaceOperation: (MGWSDLInterfaceOperation *) anOperation {
    [interfaceOperations setValue: anOperation forKey: [anOperation name]];
    [anOperation setParent: self];
}

@end