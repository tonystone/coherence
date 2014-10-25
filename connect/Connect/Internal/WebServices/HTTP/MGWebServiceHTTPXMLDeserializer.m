//
//  MGWebServiceHTTPXMLDeserializer.m
//  MGConnect
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWebServiceHTTPXMLDeserializer.h"
#import "MGWebServiceOutMessage.h"

@implementation MGWebServiceHTTPXMLDeserializer

- (MGWebServiceOutMessage *) deserializedResponse: (NSHTTPURLResponse *) aResponse responseData: (NSData *) data {
    MGWebServiceOutMessage * outMessage = [[MGWebServiceOutMessage alloc] init];
    
    [outMessage setResponseData: data];
    
    return outMessage;
}

@end
