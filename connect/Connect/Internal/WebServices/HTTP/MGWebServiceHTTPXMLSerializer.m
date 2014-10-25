//
//  MGWebServiceHTTPXMLSerializer.m
//  MGConnect
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWebServiceHTTPXMLSerializer.h"
#import "MGWebServiceInMessage.h"

@implementation MGWebServiceHTTPXMLSerializer

- (NSURL *) serializedURLForMethod:(MGWSDLHTTPExtensionMethod) method inMessage:(MGWebServiceInMessage *)inMessage {
    return [[NSURL alloc] initWithString: [self tokenizedIRI: inMessage uncitedTokens: nil]];
}

- (NSData *) serializedMessageBodyForMethod:(MGWSDLHTTPExtensionMethod) method inMessage:(MGWebServiceInMessage *)inMessage {
    NSData  * body  = nil;
    
    if (method == MGWSDLHTTPExtensionMethodPOST || method == MGWSDLHTTPExtensionMethodPUT) {
        
        if ([inMessage instanceData]) {
            // TODO
        }
    }
    return body;
}

@end
