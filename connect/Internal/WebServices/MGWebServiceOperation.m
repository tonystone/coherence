//
//  MGWebServiceOperation.m
//  MGConnect
//
//  Created by Tony Stone on 4/9/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWebServiceOperation.h"
#import "MGWebService.h"
#import "MGWSDL.h"

@implementation MGWebServiceOperation

- (NSString *) name {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (MGWebServiceOutMessage *) execute: (MGWebServiceInMessage *) inMessage {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

@end


@implementation MGWebServiceOperation (Initialization)

- (id) initWithBindingBindingDefinition: (MGWSDLBinding *) aBindingDefinition operationDefinition: (MGWSDLBindingOperation *) aBindingOperation  endpointDefinition: (MGWSDLEndpoint *) anEndpointDefinition webService: (MGWebService __unsafe_unretained *) aWebService {
    return [super init];
}

@end
