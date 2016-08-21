//
//  MGWSDLBindingFaultReference.h
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLExtendableComponent.h"

@class MGWSDLInterfaceFaultReference;
@class MGWSDLBindingOperation;

@interface MGWSDLBindingFaultReference : MGWSDLExtendableComponent

- (MGWSDLInterfaceFaultReference *) interfaceFaultReference;
- (MGWSDLBindingOperation *) parent;

@end

@interface MGWSDLBindingFaultReference (Initialization)

- (id) initWithName: (NSString *) name interfaceFaultReference: (MGWSDLInterfaceFaultReference *) anInterfaceFaultReference;
- (void) setParent: (MGWSDLBindingOperation *) aParent;

@end