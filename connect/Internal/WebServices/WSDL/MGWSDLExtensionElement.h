//
//  MGWSDLExtensionElement.h
//  MGConnect
//
//  Created by Tony Stone on 4/11/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLComponent.h"

@interface MGWSDLExtensionElement : MGWSDLComponent

- (NSString *) element;
- (NSString *) type;
- (BOOL)       required;
- (id)         value;

@end


@interface MGWSDLExtensionElement (Initialization)

- (id) initWithName:(NSString *)name element: (NSString *) anElement type: (NSString *) aType required: (BOOL) isRequired;

- (void) setValue: (id) aValue;

@end
