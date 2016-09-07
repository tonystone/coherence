//
//  MGWSDLDescription.h
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGWSDLComponent.h"

@interface MGWSDLDescription : MGWSDLComponent

- (NSDictionary *) interfaces;
- (NSDictionary *) bindings;
- (NSDictionary *) services;

- (NSDictionary *) elementDeclarations;
- (NSDictionary *) typeDefinitions;

@end

@class MGWSDLInterface;
@class MGWSDLBinding;
@class MGWSDLService;
@class MGWSDLElementDeclaration;
@class MGWSDLTypeDefinition;

@interface MGWSDLDescription (Initialization)

- (id) init;

- (void) addInterface: (MGWSDLInterface *) anInterface;
- (void)   addBinding: (MGWSDLBinding *)   aBinding;
- (void)   addService: (MGWSDLService *)   aService;

- (void) addElementDeclaration: (MGWSDLElementDeclaration *) anElementDeclaration;
- (void)     addTypeDefinition: (MGWSDLTypeDefinition *)     aTypeDefinition;

@end