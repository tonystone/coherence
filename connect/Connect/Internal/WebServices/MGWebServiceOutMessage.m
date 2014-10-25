//
//  MGWebServiceOutMessage.m
//  MGConnect
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWebServiceOutMessage.h"

@implementation MGWebServiceOutMessage {
    id responseData;
}

- (id) responseData {
    return responseData;
}

- (void) setResponseData: (id) data {
    if (responseData != data) {
        responseData = data;
    }
}

@end
