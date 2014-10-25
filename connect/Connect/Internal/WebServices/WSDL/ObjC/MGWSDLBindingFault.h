//
//  MGWSDLBindingFault.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLComponent.h"

@class MGWSDLInterfaceFault;
@class MGWSDLBinding;

@interface MGWSDLBindingFault : MGWSDLComponent

- (MGWSDLInterfaceFault *) interfaceFault;
- (MGWSDLBinding *) parent;

@end

@interface MGWSDLBindingFault (Initialization)

- (id) initWithName: (NSString *) name interfaceFault: (MGWSDLInterfaceFault *) anInterfaceFault;
- (void) setParent: (MGWSDLBinding *) aParent;

@end
