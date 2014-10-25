//
//  MGWebServiceHTTPDeserializer.m
//  MGResourceManager
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWebServiceHTTPDeserializer.h"

@implementation MGWebServiceHTTPDeserializer

- (MGWebServiceOutMessage *) deserializedResponse: (NSHTTPURLResponse *) aResponse responseData: (NSData *) returnedData {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

@end


@implementation MGWebServiceHTTPDeserializer (Initialization)


@end