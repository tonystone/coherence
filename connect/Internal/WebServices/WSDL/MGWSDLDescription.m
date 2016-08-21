//
//  MGWSDLDescription.m
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLDescription.h"
#import "MGWSDLInterface.h"
#import "MGWSDLBinding.h"
#import "MGWSDLService.h"
#import "MGWSDLElementDeclaration.h"
#import "MGWSDLTypeDefinition.h"

@implementation MGWSDLDescription {
    NSMutableDictionary * interfaces;
    NSMutableDictionary * bindings;
    NSMutableDictionary * services;
    NSMutableDictionary * elementDeclarations;
    NSMutableDictionary * typeDefinitions;
}

- (NSDictionary *) interfaces {
    return [NSDictionary dictionaryWithDictionary: interfaces];
}

- (NSDictionary *) bindings {
    return [NSDictionary dictionaryWithDictionary: bindings];
}

- (NSDictionary *) services {
    return [NSDictionary dictionaryWithDictionary: services];
}

- (NSDictionary *) elementDeclarations {
    return [NSDictionary dictionaryWithDictionary: elementDeclarations];
}

- (NSDictionary *) typeDefinitions {
    return [NSDictionary dictionaryWithDictionary: typeDefinitions];
}

- (NSString *) description {
    return [self descriptionForLevel: 0];
}

- (NSString *) descriptionForLevel: (NSUInteger) level {

    NSMutableString * description = [NSMutableString stringWithFormat: @"<%@ : %p>: ", NSStringFromClass([self class]), self];
    
    [description appendString: [self dictionaryString: interfaces          name: @"interfaces"          level: level+1]];
    [description appendString: [self dictionaryString: bindings            name: @"bindings"            level: level+1]];
    [description appendString: [self dictionaryString: services            name: @"services"            level: level+1]];
    [description appendString: [self dictionaryString: elementDeclarations name: @"elementDeclarations" level: level+1]];
    [description appendString: [self dictionaryString: typeDefinitions     name: @"typeDefinitions"     level: level+1]];
    
    return description;
}

@end


@implementation MGWSDLDescription (Initialization)

- (id) init {
    
    if ((self = [super init])) {
        interfaces          = [[NSMutableDictionary alloc] init];
        bindings            = [[NSMutableDictionary alloc] init];
        services            = [[NSMutableDictionary alloc] init];
        elementDeclarations = [[NSMutableDictionary alloc] init];
        typeDefinitions     = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void) addInterface: (MGWSDLInterface *) anInterface {
    [interfaces setValue: anInterface forKey: [anInterface name]];
}

- (void) addBinding: (MGWSDLBinding *) aBinding {
    [bindings setValue: aBinding forKey: [aBinding name]];
}

- (void) addService: (MGWSDLService *) aService {
    [services setValue: aService forKey: [aService name]];
}

- (void) addElementDeclaration: (MGWSDLElementDeclaration *) anElementDeclaration {
    [elementDeclarations setValue: anElementDeclaration forKey: [anElementDeclaration name]];
}

- (void) addTypeDefinition: (MGWSDLTypeDefinition *) aTypeDefinition {
    [typeDefinitions setValue: aTypeDefinition forKey: [aTypeDefinition name]];
}

@end
