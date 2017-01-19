//
//  MGWSDLBinding.h
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLExtendableComponent.h"

@class MGWSDLBindingFault;
@class MGWSDLBindingOperation;
@class MGWSDLInterface;

@interface MGWSDLBinding : MGWSDLExtendableComponent

- (NSString *) type;
- (MGWSDLInterface *) interface;
- (NSDictionary *) bindingFaults;
- (NSDictionary *) bindingOperations;

@end


@interface MGWSDLBinding (Initialization)

- (id) initWithName:(NSString *)name type: (NSString *) type;

- (void) setInterface: (MGWSDLInterface __unsafe_unretained *) anInterface;

- (void) addBindingFault: (MGWSDLBindingFault *) aBindingFault;
- (void) addBindingOperation: (MGWSDLBindingOperation *) aBindingOperation;

@end
