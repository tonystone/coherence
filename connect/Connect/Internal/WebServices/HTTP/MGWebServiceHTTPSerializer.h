//
//  MGWebServiceHTTPSerializer.h
//  MGConnect
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGWSDL+HTTP.h"

@class MGWebServiceInMessage;
@class MGWSDLBindingMessageReference;
@class MGWSDLBindingOperation;
@class MGWSDLEndpoint;

@interface MGWebServiceHTTPSerializer : NSObject {
@package
    NSString * address;
    NSString * location;
    NSString * queryParameterSeparator;
    BOOL       ignoreUncited;
}

- (NSURL *)          serializedURLForMethod: (MGWSDLHTTPExtensionMethod) aMethod inMessage: (MGWebServiceInMessage *) inMessage;
- (NSData *) serializedMessageBodyForMethod: (MGWSDLHTTPExtensionMethod) aMethod inMessage: (MGWebServiceInMessage *) inMessage;

@end

@interface MGWebServiceHTTPSerializer (SubclassHelperMethods)

- (NSMutableString *) tokenizedIRI: (MGWebServiceInMessage *) inMessage uncitedTokens: (NSArray * __autoreleasing *) uncitedTokens;
- (NSString *) parameterStringForInMessage: (MGWebServiceInMessage *) inMessage uncitedTokens: (NSArray *) uncitedTokens;

@end

@interface MGWebServiceHTTPSerializer (Initialization)

- (id) initWithBindingOperationDefinition: (MGWSDLBindingOperation *) aBindingOperation endpointDefinition: (MGWSDLEndpoint *) anEndpointDefinition messageReference: (MGWSDLBindingMessageReference *) aBindingMessageReference;

@end