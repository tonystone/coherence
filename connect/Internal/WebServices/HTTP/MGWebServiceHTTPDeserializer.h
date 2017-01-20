//
//  MGWebServiceHTTPDeserializer.h
//  MGConnect
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGWSDL+HTTP.h"

@class MGWebServiceOutMessage;
@class MGWSDLBindingMessageReference;
@class MGWSDLBindingOperation;

@interface MGWebServiceHTTPDeserializer : NSObject

- (MGWebServiceOutMessage *) deserializedResponse: (NSHTTPURLResponse *) aResponse responseData: (NSData *) returnedData;

@end

@interface MGWebServiceHTTPDeserializer (Initialization)

@end
