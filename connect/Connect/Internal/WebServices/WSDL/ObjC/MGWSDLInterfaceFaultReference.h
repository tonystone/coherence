//
//  MGWSDLInterfaceFaultReference.h
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLExtendableComponent.h"
#import "MGWSDL+Types.h"

@class MGWSDLInterfaceFault;
@class MGWSDLInterfaceOperation;

@interface MGWSDLInterfaceFaultReference : MGWSDLExtendableComponent

- (NSString *)             messageLabel;
- (MGWSDLMessageDirection) direction;
- (MGWSDLInterfaceFault *) interfaceFault;
- (MGWSDLInterfaceOperation *) parent;

@end


@interface MGWSDLInterfaceFaultReference (Initialization)

- (id) initWithInterfaceFault: (MGWSDLInterfaceFault *) anInterfaceFault messageLabel: (NSString *) aMessageLabel direction: (MGWSDLMessageDirection) aDirection;
- (void) setParent: (MGWSDLInterfaceOperation *) aParent;

@end