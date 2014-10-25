//
//  MGWebServiceOperation.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/9/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MGWebServiceMessage;
@class MGWebServiceInMessage;
@class MGWebServiceOutMessage;
@class MGWebServiceBindingOperation;
@class MGWSDLBinding;
@class MGWSDLEndpoint;

@interface MGWebServiceOperation : NSObject

/**
 */
- (NSString *) name;

/**
 */
- (MGWebServiceOutMessage *) execute: (MGWebServiceInMessage *) inMessage;

@end

@class MGWSDLBindingOperation;
@class MGWebService;
@class MGWebServiceEndpoint;

@interface MGWebServiceOperation (Initialization)

- (id) initWithBindingBindingDefinition: (MGWSDLBinding *) aBindingDefinition operationDefinition: (MGWSDLBindingOperation *) aBindingOperation  endpointDefinition: (MGWSDLEndpoint *) anEndpointDefinition webService: (MGWebService __unsafe_unretained *) aWebService;

@end
