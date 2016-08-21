//
//  MGWebServiceHTTPJSONSerializer.m
//  MGConnect
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWebServiceHTTPJSONSerializer.h"
#import "MGWebServiceInMessage.h"

@implementation MGWebServiceHTTPJSONSerializer

- (NSURL *) serializedURLForMethod:(MGWSDLHTTPExtensionMethod) method inMessage:(MGWebServiceInMessage *)inMessage {
    return [[NSURL alloc] initWithString: [self tokenizedIRI: inMessage uncitedTokens: nil]];
}

- (NSData *) serializedMessageBodyForMethod:(MGWSDLHTTPExtensionMethod) method inMessage:(MGWebServiceInMessage *)inMessage {
    NSData  * body  = nil;
    
    if (method == MGWSDLHTTPExtensionMethodPOST || method == MGWSDLHTTPExtensionMethodPUT) {

        NSError * error = nil;
        
        if ([inMessage instanceData]) {
            body = [NSJSONSerialization dataWithJSONObject: [inMessage instanceData] options: 0 error: &error];
        }
    }
    return body;
}

@end
