//
//  MGWebServiceHTTPURLEncodedSerializer.m
//  MGResourceManager
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWebServiceHTTPURLEncodedSerializer.h"
#import "MGWebServiceInMessage.h"
#import "MGRuntimeException.h"

@implementation MGWebServiceHTTPURLEncodedSerializer

- (NSURL *) serializedURLForMethod:(MGWSDLHTTPExtensionMethod) method inMessage:(MGWebServiceInMessage *)inMessage {
    NSArray         * uncitedTokens   = nil;
    NSMutableString * iriString       = [self tokenizedIRI: inMessage uncitedTokens: &uncitedTokens];
    
    if (!ignoreUncited && (method == MGWSDLHTTPExtensionMethodGET || method == MGWSDLHTTPExtensionMethodDELETE)) {
        
        NSString * parameterString = [self parameterStringForInMessage: inMessage uncitedTokens: uncitedTokens];
        
        if (parameterString) {
            NSRange parameterStartMarkerRange = [iriString rangeOfString: @"?"];
            
            if (parameterStartMarkerRange.location == NSNotFound) {
                // There are no existing properties so append these with a marker
                [iriString appendFormat: @"?%@", parameterString];
            } else {
                // Parameters already exist so we need to add the queryParameterSeparator
                [iriString appendFormat: @"%@%@", queryParameterSeparator, parameterString];
            }
        }
    }
    return [[NSURL alloc] initWithString: iriString];
}

- (NSData *) serializedMessageBodyForMethod:(MGWSDLHTTPExtensionMethod) method inMessage:(MGWebServiceInMessage *)inMessage {
    
    if (method == MGWSDLHTTPExtensionMethodPOST || method == MGWSDLHTTPExtensionMethodPUT) {
        NSString * body = [self parameterStringForInMessage: inMessage uncitedTokens: nil];
        
        if (body) {
            return [body dataUsingEncoding: NSUTF8StringEncoding];
        }
    }
    // Body not allowed or empty
    return nil;
}

@end
