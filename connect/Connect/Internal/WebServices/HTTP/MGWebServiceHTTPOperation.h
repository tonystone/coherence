//
//  MGWebServiceOperationHTTPBinding.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/9/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWebServiceOperation.h"

@class MGWSDLBindingOperation;
@class MGWSDLEndpoint;
@class MGWSDLBinding;

@interface MGWebServiceHTTPOperation : MGWebServiceOperation

@end

@interface MGWebServiceHTTPOperation (Initialization)

- (id) initWithBindingBindingDefinition: (MGWSDLBinding *) aBindingDefinition operationDefinition: (MGWSDLBindingOperation *) aBindingOperation  endpointDefinition: (MGWSDLEndpoint *) anEndpointDefinition webService: (MGWebService __unsafe_unretained *) aWebService;

@end
