//
//  MGWSDLEndpoint.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLExtendableComponent.h"

@class MGWSDLService;
@class MGWSDLBinding;

@interface MGWSDLEndpoint : MGWSDLExtendableComponent

- (MGWSDLBinding *) binding;
- (MGWSDLService *) parent;

- (NSString *) address;

@end


@interface MGWSDLEndpoint (Initialization)

- (id) initWithName: (NSString *) name binding: (MGWSDLBinding *) aBinding;
- (void) setParent: (MGWSDLService __unsafe_unretained *) aParent;

- (void) setAddress: (NSString *) anAddress;

@end