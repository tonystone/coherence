//
//  MGWebServiceHTTPJSONDeserializer.m
//  MGConnect
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWebServiceHTTPJSONDeserializer.h"
#import "MGWebServiceOutMessage.h"

@implementation MGWebServiceHTTPJSONDeserializer

- (MGWebServiceOutMessage *) deserializedResponse: (NSHTTPURLResponse *) aResponse responseData: (NSData *) data {
    MGWebServiceOutMessage * outMessage = [[MGWebServiceOutMessage alloc] init];
  
    NSError * error = nil;
    
    [outMessage setResponseData: [NSJSONSerialization JSONObjectWithData: data options: 0 error: &error]];

    return outMessage;
}

@end
