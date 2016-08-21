//
//  MGWSDLInterface.h
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGWSDLExtendableComponent.h"

@interface MGWSDLInterface : MGWSDLExtendableComponent

- (NSDictionary *) extendedInterfaces;
- (NSDictionary *) interfaceFaults;
- (NSDictionary *) interfaceOperations;

@end


@class MGWSDLInterfaceFault;
@class MGWSDLInterfaceOperation;

@interface MGWSDLInterface (Initialization)

- (id) initWithName: (NSString *) name;

- (void)  addExtendedInterface: (MGWSDLInterface *)          anInterface;
- (void)     addInterfaceFault: (MGWSDLInterfaceFault *)     aFault;
- (void) addInterfaceOperation: (MGWSDLInterfaceOperation *) anOperation;

@end