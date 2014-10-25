//
//  MGWSDLBindingOperation.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLExtendableComponent.h"

@class MGWSDLBinding;
@class MGWSDLInterfaceOperation;
@class MGWSDLBindingMessageReference;
@class MGWSDLBindingFaultReference;

@interface MGWSDLBindingOperation : MGWSDLExtendableComponent

- (MGWSDLInterfaceOperation *) interfaceOperation;
- (NSDictionary *) bindingMessageReferences;
- (NSDictionary *) bindingFaultReferences;
- (MGWSDLBinding *) parent;

@end

@interface MGWSDLBindingOperation (Initialization)

- (id) initWithName:(NSString *)name interfaceOperation: (MGWSDLInterfaceOperation *) anInterfaceOperation;

- (void) addBindingMessageReference: (MGWSDLBindingMessageReference *) aBindingMessageReference;
- (void)   addBindingFaultReference: (MGWSDLBindingFaultReference *)   aBindingFaultReference;
- (void) setParent: (MGWSDLBinding __unsafe_unretained *) aParent;

@end
