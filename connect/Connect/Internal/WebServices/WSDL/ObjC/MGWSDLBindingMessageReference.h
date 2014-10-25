//
//  MGWSDLBindingMessageReference.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLExtendableComponent.h"
#import "MGWSDLInterfaceMessageReference.h"
#import "MGWSDLBindingOperation.h"

@class MGWSDLInterfaceMessageReference;

@interface MGWSDLBindingMessageReference : MGWSDLExtendableComponent

- (MGWSDLInterfaceMessageReference *) interfaceMessageReference;
- (MGWSDLBindingOperation *)          parent;

@end


@interface MGWSDLBindingMessageReference (Initialization)

- (id) initWithName: (NSString *) name interfaceMessageReference: (MGWSDLInterfaceMessageReference *) anInterfaceMessage;
- (void) setParent: (MGWSDLBindingOperation __unsafe_unretained *) aParent;

@end